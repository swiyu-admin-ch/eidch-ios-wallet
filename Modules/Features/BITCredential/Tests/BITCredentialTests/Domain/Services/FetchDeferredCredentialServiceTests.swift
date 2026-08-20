// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

final class FetchDeferredCredentialServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    service = FetchDeferredCredentialService()
    success()
  }

  func testCallAsFunction_success() async throws {
    let (metadataJws, result) = try await service(for: deferredCredentialMock)

    XCTAssertEqual(metadataJws, metadataJwsMock)

    if case .credential(let credentials) = result {
      XCTAssertEqual(credentials.first?.raw, anyCredential.raw)
    } else {
      XCTFail("Expected credential result")
    }

    XCTAssertEqual(openIDRepositorySpy.fetchMetadataFromReceivedIssuerUrl, deferredCredentialMock.issuerUrl)
    XCTAssertEqual(actorIdentityValidatorSpy.validateCallsCount, 1)
    XCTAssertEqual(actorIdentityValidatorSpy.validateReceivedMetadataJws, metadataJwsMock)
    XCTAssertEqual(credentialEncryptionContextGeneratorSpy.callAsFunctionForReceivedMetadata, metadataJwsMock.payload.credentialIssuerMetadata)

    guard let arguments = openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestReceivedArguments else {
      XCTFail("No arguments received")
      return
    }
    XCTAssertEqual(arguments.context.authorization.accessToken.accessToken, deferredCredentialMock.authentication.accessToken)
    XCTAssertEqual(arguments.context.format, deferredCredentialMock.format)
    XCTAssertEqual(arguments.context.deferredCredentialEndpoint, Self.deferredCredentialEndpoint)
    XCTAssertEqual(arguments.context.authorization.refreshToken, deferredCredentialMock.authentication.refreshToken)
    XCTAssertEqual(arguments.context.credentialEncryptionContext.credentialResponseEncryptionAlgorithm, credentialEncryptionContextMock.credentialResponseEncryptionAlgorithm)
    XCTAssertEqual(arguments.context.credentialEncryptionContext.credentialResponseEncryptionZipValue, credentialEncryptionContextMock.credentialResponseEncryptionZipValue)
    XCTAssertEqual(arguments.context.credentialEncryptionContext.responseKeyPair, credentialEncryptionContextMock.responseKeyPair)

    XCTAssertEqual(arguments.deferredCredentialRequest.transactionId, deferredCredentialMock.transactionId)
    XCTAssertEqual(arguments.deferredCredentialRequest.credentialResponseEncryption.enc, credentialEncryptionContextMock.credentialResponseEncryptionAlgorithm.rawValue)
    XCTAssertEqual(arguments.deferredCredentialRequest.credentialResponseEncryption.zip, credentialEncryptionContextMock.credentialResponseEncryptionZipValue?.rawValue)
  }

  func testCallAsFunction_openIDRepositoryThrows_throwsError() async {
    openIDRepositorySpy.fetchMetadataFromThrowableError = TestingError.error

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_invalidActorIdentity_terminatesInteraction() async {
    actorIdentityValidatorSpy.validateThrowableError = GovernanceError.unverifiedActor

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected unverified actor error")
    } catch {
      XCTAssertEqual(error as? GovernanceError, .unverifiedActor)
      XCTAssertFalse(credentialEncryptionContextGeneratorSpy.callAsFunctionForCalled)
      XCTAssertFalse(openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestCalled)
    }
  }

  func testCallAsFunction_withIdentityTrustStatement_validatorArgumentsPassed() async throws {
    let metadataJws = Self.makeMetadataJws(deferredCredentialEndpoint: Self.deferredCredentialEndpoint)
    openIDRepositorySpy.fetchMetadataFromReturnValue = metadataJws

    _ = try await service(for: deferredCredentialMock)

    XCTAssertEqual(actorIdentityValidatorSpy.validateReceivedMetadataJws, metadataJws)
  }

  func testCallAsFunction_credentialEncryptionContextGeneratorThrows_throwsError() async {
    credentialEncryptionContextGeneratorSpy.callAsFunctionForThrowableError = TestingError.error

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_missingDeferredCredentialEndpoint_throws() async {
    openIDRepositorySpy.fetchMetadataFromReturnValue = Self.makeMetadataJws(deferredCredentialEndpoint: nil)

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? FetchDeferredCredentialServiceError, .missingDeferredCredentialURL)
      XCTAssertFalse(openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestCalled)
    }
  }

  func testCallAsFunction_accessTokenIsExpired_renewTokenAndRetry() async throws {
    openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestClosure = { _, _ in
      if self.openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestCallsCount == 1 {
        throw OpenIdRepositoryError.expiredAccessToken
      }

      return .credential([self.anyCredential])
    }

    let (_, _) = try await service(for: deferredCredentialMock)

    XCTAssertEqual(openIDRepositorySpy.fetchOpenIdConfigurationFromCallsCount, 1)
    XCTAssertEqual(openIDRepositorySpy.fetchOpenIdConfigurationFromReceivedIssuerURL, deferredCredentialMock.issuerUrl)

    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceCallsCount, 1)
    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.refreshToken, deferredCredentialMock.authentication.refreshToken)
    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.url, OpenIdConfiguration.Mock.sample.tokenEndpoint)
    XCTAssertNotNil(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.dpopKeyPair)
    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.dpopNonce, Self.dpopNonce)

    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestCallsCount, 2)
    guard let arguments = openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestReceivedArguments else {
      XCTFail("No arguments received")
      return
    }
    XCTAssertEqual(arguments.context.authorization.accessToken.accessToken, AccessToken.Mock.sample.accessToken)
    XCTAssertEqual(arguments.context.authorization.refreshToken, AccessToken.Mock.sample.refreshToken)
    XCTAssertEqual(arguments.deferredCredentialRequest.transactionId, deferredCredentialMock.transactionId)
    XCTAssertEqual(arguments.deferredCredentialRequest.credentialResponseEncryption.enc, credentialEncryptionContextMock.credentialResponseEncryptionAlgorithm.rawValue)
  }

  func testCallAsFunction_accessTokenIsExpiredWithDPoP_refreshesWithDPoPAndPreservesRefreshToken() async throws {
    let deferredCredential = try DeferredCredential.Mock.sample(
      dpopBinding: KeyBinding(
        id: XCTUnwrap(UUID(uuidString: dpopKeyPairMock.identifier)),
        algorithm: dpopKeyPairMock.algorithm.rawValue,
        bindingType: .software))

    openIDRepositorySpy.fetchMetadataFromReturnValue = metadataJwsMock
    openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestClosure = { _, _ in
      if self.openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestCallsCount == 1 {
        throw OpenIdRepositoryError.expiredAccessToken
      }

      return .deferred(DeferredCredentialContext.Mock.sample)
    }
    openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReturnValue = refreshedAuthorizationWithoutRefreshTokenMock

    let (_, result) = try await service(for: deferredCredential)

    XCTAssertEqual(openIDRepositorySpy.fetchNonceFromCallsCount, 3)
    XCTAssertEqual(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.identifier, dpopKeyPairMock.identifier)
    XCTAssertEqual(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.algorithm, dpopKeyPairMock.algorithm)
    XCTAssertNil(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.query)
    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.dpopKeyPair?.identifier, dpopKeyPairMock.identifier)
    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.dpopNonce, Self.dpopNonce)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestReceivedArguments?.context.authorization.dpopKeyPair?.identifier, dpopKeyPairMock.identifier)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestReceivedArguments?.context.authorization.resourceServerDPoPNonce, Self.dpopNonce)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestReceivedArguments?.context.authorization.refreshToken, DeferredCredential.Mock.refreshToken)

    if case .deferred(let deferred) = result {
      XCTAssertEqual(deferred.accessToken.refreshToken, AccessToken.Mock.sample.refreshToken)
    } else {
      XCTFail("Expected deferred result")
    }
  }

  func testCallAsFunction_accessTokenIsExpiredWithoutRefreshToken_throwsMissingRefreshToken() async {
    openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestThrowableError = OpenIdRepositoryError.expiredAccessToken

    do {
      _ = try await service(for: .Mock.sampleWithoutRefreshToken)
    } catch {
      XCTAssertEqual(error as? FetchDeferredCredentialServiceError, .missingRefreshToken)
      XCTAssertEqual(openIDRepositorySpy.fetchOpenIdConfigurationFromCallsCount, 0)
      XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceCallsCount, 0)
      XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestCallsCount, 1)
    }
  }

  // MARK: Private

  private static let deferredCredentialEndpoint = URL(string: "https://deferred")!
  private static let nonceEndpoint = URL(string: "https://nonce")!
  private static let dpopNonce = "dpopNonce"

  private var openIDRepositorySpy: OpenIDRepositoryProtocolSpy!
  private var trustStatementValidatorSpy: TrustStatementValidatorProtocolSpy<IdentityTrustStatementJWT>!
  private var credentialEncryptionContextGeneratorSpy: CredentialEncryptionContextGeneratorProtocolSpy!
  private var keyManagerSpy: KeyManagerProtocolSpy!
  private var actorIdentityValidatorSpy: ActorIdentityValidatorProtocolSpy!
  private var service: FetchDeferredCredentialService!

  private let deferredCredentialMock = DeferredCredential.Mock.sample
  private let anyCredential: AnyCredential = MockAnyCredential()

  private let metadataJwsMock = makeMetadataJws(deferredCredentialEndpoint: deferredCredentialEndpoint)
  private let credentialEncryptionContextMock = CredentialEncryptionContext(
    issuerPublicKey: JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue),
    credentialRequestEncryptionAlgorithm: .A128GCM,
    credentialRequestEncryptionZipValue: .deflate,
    responseKeyPair: VaultKeyPair.Mock.ES256,
    credentialResponseEncryptionAlgorithm: .A128GCM,
    credentialResponseEncryptionZipValue: .deflate)
  private let dpopKeyPairMock = VaultKeyPair.Mock.ES256

  private var refreshedAuthorizationWithoutRefreshTokenMock: IssuanceAuthorization {
    IssuanceAuthorization(
      accessToken: AccessToken(
        accessToken: AccessToken.Mock.sample.accessToken,
        tokenType: AccessToken.Mock.sample.tokenType),
      dpopKeyPair: dpopKeyPairMock)
  }

  private static func makeMetadataJws(
    nonceEndpoint: URL = nonceEndpoint,
    deferredCredentialEndpoint: URL? = deferredCredentialEndpoint)
    -> JWS<CredentialIssuerMetadataJWT>
  {
    var metadata = CredentialIssuerMetadata.Mock.sample
    metadata = metadata.changing(\.nonceEndpoint, to: nonceEndpoint)
    metadata = metadata.changing(\.deferredCredentialEndpoint, to: deferredCredentialEndpoint)
    return CredentialIssuerMetadataJWT.Mock.createJWS(from: metadata)
  }

  private func registerMocks() {
    openIDRepositorySpy = OpenIDRepositoryProtocolSpy()
    trustStatementValidatorSpy = TrustStatementValidatorProtocolSpy()
    credentialEncryptionContextGeneratorSpy = CredentialEncryptionContextGeneratorProtocolSpy()
    keyManagerSpy = KeyManagerProtocolSpy()
    actorIdentityValidatorSpy = ActorIdentityValidatorProtocolSpy()

    Container.shared.openIDRepository.register { self.openIDRepositorySpy }
    Container.shared.trustStatementValidator.register { self.trustStatementValidatorSpy }
    Container.shared.credentialEncryptionContextGenerator.register { self.credentialEncryptionContextGeneratorSpy }
    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.actorIdentityValidator.register { self.actorIdentityValidatorSpy }
    Container.shared.isDPoPEnabled.register { true }
  }

  private func success() {
    openIDRepositorySpy.fetchMetadataFromReturnValue = metadataJwsMock
    openIDRepositorySpy.fetchCredentialWithDeferredCredentialRequestReturnValue = .credential([anyCredential])
    openIDRepositorySpy.fetchOpenIdConfigurationFromReturnValue = .Mock.sample
    openIDRepositorySpy.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReturnValue = IssuanceAuthorization(accessToken: .Mock.sample)
    openIDRepositorySpy.fetchNonceFromReturnValue = (nonce: .Mock.default, dpopNonce: Self.dpopNonce)
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReturnValue = dpopKeyPairMock
    credentialEncryptionContextGeneratorSpy.callAsFunctionForReturnValue = credentialEncryptionContextMock
  }

}
