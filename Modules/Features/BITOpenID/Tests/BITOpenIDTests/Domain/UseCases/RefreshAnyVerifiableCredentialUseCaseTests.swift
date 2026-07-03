import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class RefreshAnyVerifiableCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()

    useCase = RefreshAnyVerifiableCredentialUseCase()
  }

  func testCallAsFunction_validArguments_createsValidContextAndFetches() async throws {
    let execution = try await useCase(
      metadataWrapper: metadataWrapper,
      holderBindings: holderBindings,
      authorization: IssuanceAuthorization(accessToken: accessToken))

    if case .credential(let credential) = execution.credentials {
      XCTAssertEqual(credential.raw, anyCredential.raw)
    } else {
      XCTFail("Expected credential response")
    }

    XCTAssertEqual(execution.authorization.accessToken.accessToken, accessToken.accessToken)
    XCTAssertEqual(execution.authorization.accessToken.tokenType, accessToken.tokenType)
    XCTAssertEqual(execution.authorization.accessToken.refreshToken, accessToken.refreshToken)

    XCTAssertEqual(repository.fetchNonceFromCallsCount, 1)
    XCTAssertEqual(repository.fetchNonceFromReceivedUrl, metadataWrapper.credentialIssuerMetadata.nonceEndpoint)
    XCTAssertEqual(credentialEncryptionContextGenerator.callAsFunctionForCallsCount, 1)

    guard let context = fetchAnyCredentialUseCase.executeForReceivedContext else {
      return XCTFail("Expected fetch context")
    }

    XCTAssertEqual(context.credentialConfigurationId, metadataWrapper.credentialConfigurationId)
    XCTAssertEqual(context.format, metadataWrapper.selectedCredential.format)
    XCTAssertEqual(context.credentialIssuer, metadataWrapper.credentialIssuerMetadata.credentialIssuer)
    XCTAssertEqual(context.holderBindings, holderBindings)
    XCTAssertEqual(context.authorization, IssuanceAuthorization(accessToken: accessToken))
    XCTAssertEqual(context.nonce, nonce)
    XCTAssertEqual(context.credentialEndpoint.absoluteString, metadataWrapper.credentialIssuerMetadata.credentialEndpoint)
    XCTAssertEqual(context.credentialEncryptionContext, encryptionContext)
    XCTAssertEqual(context.deferredCredentialEndpoint, metadataWrapper.credentialIssuerMetadata.deferredCredentialEndpoint)
  }

  func testCallAsFunction_expiredAccessToken_refreshesTokenAndRetries() async throws {
    fetchAnyCredentialUseCase.executeForClosure = { context in
      if self.fetchAnyCredentialUseCase.executeForCallsCount == 1 {
        throw OpenIdRepositoryError.expiredAccessToken
      }

      XCTAssertEqual(context.accessToken, self.refreshedAccessToken)
      return .credential(self.anyCredential)
    }

    let execution = try await useCase(
      metadataWrapper: metadataWrapper,
      holderBindings: holderBindings,
      authorization: IssuanceAuthorization(accessToken: accessToken))

    XCTAssertEqual(repository.fetchOpenIdConfigurationFromCallsCount, 1)
    XCTAssertEqual(repository.fetchOpenIdConfigurationFromReceivedIssuerURL?.absoluteString, metadataWrapper.credentialIssuerMetadata.credentialIssuer)
    XCTAssertEqual(repository.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceCallsCount, 1)
    XCTAssertEqual(repository.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.url, openIdConfiguration.tokenEndpoint)
    XCTAssertEqual(repository.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReceivedArguments?.refreshToken, accessToken.refreshToken)
    XCTAssertEqual(fetchAnyCredentialUseCase.executeForCallsCount, 2)
    XCTAssertEqual(execution.authorization.accessToken.accessToken, refreshedAccessToken.accessToken)
    XCTAssertEqual(execution.authorization.accessToken.tokenType, refreshedAccessToken.tokenType)
    XCTAssertEqual(execution.authorization.accessToken.refreshToken, refreshedAccessToken.refreshToken)
  }

  func testCallAsFunction_expiredAccessTokenWithoutRefreshToken_throws() async {
    fetchAnyCredentialUseCase.executeForThrowableError = OpenIdRepositoryError.expiredAccessToken

    do {
      _ = try await useCase(
        metadataWrapper: metadataWrapper,
        holderBindings: holderBindings,
        authorization: IssuanceAuthorization(
          accessToken: AccessToken(
            accessToken: accessToken.accessToken,
            tokenType: accessToken.tokenType)))
      XCTFail("Expected expiredAccessToken")
    } catch {
      XCTAssertEqual(error as? OpenIdRepositoryError, .expiredAccessToken)
      XCTAssertFalse(repository.fetchOpenIdConfigurationFromCalled)
      XCTAssertFalse(repository.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceCalled)
    }
  }

  // MARK: Private

  private let anyCredential = AnyCredentialSpy()
  private let metadataWrapper = CredentialIssuerMetadataWrapper.Mock.sampleChasseralIssuer01
  private let holderBindings = HolderBinding.Mock.softwareKey
  private let accessToken = AccessToken.Mock.sample
  private let refreshedAccessToken = AccessToken(
    accessToken: "refreshed-access-token",
    tokenType: .bearer,
    refreshToken: "refreshed-refresh-token")
  private let nonce = Nonce.Mock.default
  private let openIdConfiguration = OpenIdConfiguration.Mock.sample
  private let encryptionContext = CredentialEncryptionContext(
    issuerPublicKey: JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue),
    credentialRequestEncryptionAlgorithm: .A128GCM,
    credentialRequestEncryptionZipValue: .deflate,
    responseKeyPair: VaultKeyPair.Mock.ES256,
    credentialResponseEncryptionAlgorithm: .A128GCM,
    credentialResponseEncryptionZipValue: .deflate)

  private var repository: OpenIDRepositoryProtocolSpy!
  private var fetchAnyCredentialUseCase: FetchAnyCredentialUseCaseProtocolSpy!
  private var credentialEncryptionContextGenerator: CredentialEncryptionContextGeneratorProtocolSpy!
  private var dispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]!
  private var useCase: RefreshAnyVerifiableCredentialUseCase!

  private func registerMocks() {
    repository = OpenIDRepositoryProtocolSpy()
    fetchAnyCredentialUseCase = FetchAnyCredentialUseCaseProtocolSpy()
    credentialEncryptionContextGenerator = CredentialEncryptionContextGeneratorProtocolSpy()
    dispatcher = [.vcSdJwt: fetchAnyCredentialUseCase]

    Container.shared.openIDRepository.register { self.repository }
    Container.shared.anyFetchCredentialDispatcher.register { self.dispatcher }
    Container.shared.credentialEncryptionContextGenerator.register { self.credentialEncryptionContextGenerator }

    anyCredential.format = CredentialFormat.vcSdJwt.rawValue
    anyCredential.raw = "refreshed-any-credential"
    anyCredential.vcSchemaId = "vcSchemaId"
    anyCredential.getClaimsJSONReturnValue = [:]
    fetchAnyCredentialUseCase.executeForReturnValue = .credential(anyCredential)
    repository.fetchNonceFromReturnValue = (nonce: nonce, dpopNonce: nil)
    repository.fetchOpenIdConfigurationFromReturnValue = openIdConfiguration
    repository.refreshAccessTokenFromRefreshTokenDpopKeyPairDpopNonceReturnValue = IssuanceAuthorization(accessToken: refreshedAccessToken)
    credentialEncryptionContextGenerator.callAsFunctionForReturnValue = encryptionContext
  }
}
