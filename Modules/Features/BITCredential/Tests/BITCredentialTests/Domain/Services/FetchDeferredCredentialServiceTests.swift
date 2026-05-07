// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
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
    let (metadata, result) = try await service(for: deferredCredentialMock)

    XCTAssertEqual(metadata.metadata.credentialIssuer, metadataResponseMock.metadata.credentialIssuer)
    XCTAssertEqual(metadata.raw, metadataResponseMock.raw)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, anyCredential.raw)
    } else {
      XCTFail("Expected credential result")
    }

    XCTAssertEqual(openIDRepositorySpy.fetchMetadataFromReceivedIssuerUrl?.absoluteString, deferredCredentialMock.issuerUrl)
    XCTAssertEqual(credentialEncryptionContextGeneratorSpy.callAsFunctionForReceivedMetadata, metadataResponseMock.metadata)
    XCTAssertEqual(deferredCredentialRequestBodyGeneratorSpy.generateTransactionIdCredentialEncryptionContextReceivedArguments?.transactionId, deferredCredentialMock.transactionId)
    XCTAssertEqual(deferredCredentialRequestBodyGeneratorSpy.generateTransactionIdCredentialEncryptionContextReceivedArguments?.credentialEncryptionContext, credentialEncryptionContextMock)

    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.context.accessToken, deferredCredentialMock.authentication.accessToken)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.context.format, deferredCredentialMock.format)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.context.deferredCredentialEndpoint, Self.deferredCredentialEndpoint)
    XCTAssertNotNil(openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.context.privateKey)

    if let requestBody = openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.requestBody {
      guard case .json(let request) = requestBody, case .json(let requestMock) = deferredCredentialRequestBodyMock else {
        XCTFail("Expected requestBody to be passed to the repository")
        return
      }
      XCTAssertEqual(request, requestMock)
    } else {
      XCTFail("Expected requestBody to be passed to the repository")
    }
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

  func testCallAsFunction_credentialEncryptionContextGeneratorThrows_throwsError() async {
    credentialEncryptionContextGeneratorSpy.callAsFunctionForThrowableError = TestingError.error

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_deferredCredentialRequestBodyGeneratorThrows_throwsError() async {
    deferredCredentialRequestBodyGeneratorSpy.generateTransactionIdCredentialEncryptionContextThrowableError = TestingError.error

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_missingDeferredCredentialEndpoint_throws() async {
    let metadataWithoutDeferredEndpoint = CredentialIssuerMetadata(
      credentialIssuer: "https://issuer",
      credentialEndpoint: "https:/credential",
      credentialConfigurationsSupported: CredentialIssuerMetadata.Mock.sample.credentialConfigurationsSupported,
      display: CredentialIssuerMetadata.Mock.sample.display)
    openIDRepositorySpy.fetchMetadataFromReturnValue = CredentialIssuerMetadataResponse(metadata: metadataWithoutDeferredEndpoint, raw: Data())

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? FetchDeferredCredentialServiceError, .missingDeferredCredentialURL)
      XCTAssertFalse(openIDRepositorySpy.fetchCredentialWithRequestBodyCalled)
    }
  }

  func testCallAsFunction_accessTokenIsExpired_renewTokenAndRetry() async throws {
    openIDRepositorySpy.fetchCredentialWithRequestBodyClosure = { _, _ in
      if self.openIDRepositorySpy.fetchCredentialWithRequestBodyCallsCount == 1 {
        throw OpenIdRepositoryError.expiredAccessToken
      }

      return .credential(self.anyCredential)
    }

    let (_, _) = try await service(for: deferredCredentialMock)

    XCTAssertEqual(openIDRepositorySpy.fetchOpenIdConfigurationFromCallsCount, 1)
    XCTAssertEqual(openIDRepositorySpy.fetchOpenIdConfigurationFromReceivedIssuerURL?.absoluteString, deferredCredentialMock.issuerUrl)

    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenCallsCount, 1)
    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenReceivedArguments?.refreshToken, deferredCredentialMock.authentication.refreshToken)
    XCTAssertEqual(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenReceivedArguments?.url, OpenIdConfiguration.Mock.sample.tokenEndpoint)

    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyCallsCount, 2)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.context.accessToken, AccessToken.Mock.sample.accessToken)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.context.refreshToken, AccessToken.Mock.sample.refreshToken)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyReceivedArguments?.requestBody, deferredCredentialRequestBodyMock)
  }

  func testCallAsFunction_accessTokenIsExpiredWithoutRefreshToken_throwsMissingRefreshToken() async {
    openIDRepositorySpy.fetchCredentialWithRequestBodyThrowableError = OpenIdRepositoryError.expiredAccessToken

    do {
      _ = try await service(for: .Mock.sampleWithoutRefreshToken)
    } catch {
      XCTAssertEqual(error as? FetchDeferredCredentialServiceError, .missingRefreshToken)
      XCTAssertFalse(openIDRepositorySpy.fetchOpenIdConfigurationFromCalled)
      XCTAssertFalse(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenCalled)
      XCTAssertEqual(openIDRepositorySpy.fetchCredentialWithRequestBodyCallsCount, 1)
    }
  }

  func testCallAsFunction_accessTokenIsExpiredWithoutIssuerUrl_throwsInvalidIssuerUrl() async {
    openIDRepositorySpy.fetchCredentialWithRequestBodyThrowableError = OpenIdRepositoryError.expiredAccessToken

    do {
      _ = try await service(for: .Mock.sampleWithoutIssuerUrl)
    } catch {
      XCTAssertEqual(error as? FetchDeferredCredentialServiceError, .invalidIssuerUrl)
      XCTAssertFalse(openIDRepositorySpy.fetchOpenIdConfigurationFromCalled)
      XCTAssertFalse(openIDRepositorySpy.refreshAccessTokenFromRefreshTokenCalled)
    }
  }

  // MARK: Private

  private static let deferredCredentialEndpoint = URL(string: "https://deferred")!

  private var openIDRepositorySpy: OpenIDRepositoryProtocolSpy!
  private var credentialEncryptionContextGeneratorSpy: CredentialEncryptionContextGeneratorProtocolSpy!
  private var deferredCredentialRequestBodyGeneratorSpy: DeferredCredentialRequestBodyGeneratorProtocolSpy!
  private var service: FetchDeferredCredentialService!

  private let deferredCredentialMock = DeferredCredential.Mock.sample
  private let anyCredential: AnyCredential = MockAnyCredential()

  private let metadataResponseMock = CredentialIssuerMetadataResponse(
    metadata: CredentialIssuerMetadata(
      credentialIssuer: "https://issuer",
      credentialEndpoint: "https://issuer/credential",
      credentialConfigurationsSupported: CredentialIssuerMetadata.Mock.sample.credentialConfigurationsSupported,
      display: CredentialIssuerMetadata.Mock.sample.display,
      deferredCredentialEndpoint: deferredCredentialEndpoint),
    raw: "raw".data(using: .utf8)!)
  private let credentialEncryptionContextMock = CredentialEncryptionContext(
    issuerPublicKey: JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue),
    credentialRequestEncryptionAlgorithm: .A128GCM,
    credentialRequestEncryptionZipValue: .deflate,
    responseKeyPair: VaultKeyPair.Mock.ES256,
    credentialResponseEncryptionAlgorithm: .A128GCM,
    credentialResponseEncryptionZipValue: .deflate)
  private let deferredCredentialRequestBodyMock = DeferredCredentialRequestBody.json(
    DeferredCredentialRequest(
      transactionId: DeferredCredential.Mock.transactionId,
      credentialResponseEncryption: nil))

  private func registerMocks() {
    openIDRepositorySpy = OpenIDRepositoryProtocolSpy()
    credentialEncryptionContextGeneratorSpy = CredentialEncryptionContextGeneratorProtocolSpy()
    deferredCredentialRequestBodyGeneratorSpy = DeferredCredentialRequestBodyGeneratorProtocolSpy()

    Container.shared.openIDRepository.register { self.openIDRepositorySpy }
    Container.shared.credentialEncryptionContextGenerator.register { self.credentialEncryptionContextGeneratorSpy }
    Container.shared.deferredCredentialRequestBodyGenerator.register { self.deferredCredentialRequestBodyGeneratorSpy }
    Container.shared.isPayloadEncryptionEnabled.register { true }
  }

  private func success() {
    openIDRepositorySpy.fetchMetadataFromReturnValue = metadataResponseMock
    openIDRepositorySpy.fetchCredentialWithRequestBodyReturnValue = .credential(anyCredential)
    openIDRepositorySpy.fetchOpenIdConfigurationFromReturnValue = .Mock.sample
    openIDRepositorySpy.refreshAccessTokenFromRefreshTokenReturnValue = .Mock.sample
    credentialEncryptionContextGeneratorSpy.callAsFunctionForReturnValue = credentialEncryptionContextMock
    deferredCredentialRequestBodyGeneratorSpy.generateTransactionIdCredentialEncryptionContextReturnValue = deferredCredentialRequestBodyMock
  }
}
