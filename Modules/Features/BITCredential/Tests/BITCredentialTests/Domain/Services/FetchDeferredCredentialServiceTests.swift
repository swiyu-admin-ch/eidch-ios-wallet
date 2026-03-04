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

    XCTAssertEqual(openIDRepositorySpy.fetchCredentialFromRequestBodyAccessTokenFormatPrivateKeyReceivedArguments?.accessToken, deferredCredentialMock.accessToken)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialFromRequestBodyAccessTokenFormatPrivateKeyReceivedArguments?.format, deferredCredentialMock.format)
    XCTAssertEqual(openIDRepositorySpy.fetchCredentialFromRequestBodyAccessTokenFormatPrivateKeyReceivedArguments?.url, Self.deferredCredentialEndpoint)
    XCTAssertNotNil(openIDRepositorySpy.fetchCredentialFromRequestBodyAccessTokenFormatPrivateKeyReceivedArguments?.privateKey)

    if let requestBody = openIDRepositorySpy.fetchCredentialFromRequestBodyAccessTokenFormatPrivateKeyReceivedArguments?.requestBody {
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
    let metadataWithoutDeferredEndpoint = CredentialMetadata(
      credentialIssuer: "https://issuer",
      credentialEndpoint: "https:/credential",
      credentialConfigurationsSupported: CredentialMetadata.Mock.sample.credentialConfigurationsSupported,
      display: CredentialMetadata.Mock.sample.display)
    openIDRepositorySpy.fetchMetadataFromReturnValue = CredentialMetadataResponse(metadata: metadataWithoutDeferredEndpoint, raw: Data())

    do {
      _ = try await service(for: deferredCredentialMock)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? FetchDeferredCredentialServiceError, .missingDeferredCredentialURL)
      XCTAssertFalse(openIDRepositorySpy.fetchCredentialFromRequestBodyAccessTokenFormatPrivateKeyCalled)
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

  private let metadataResponseMock = CredentialMetadataResponse(
    metadata: CredentialMetadata(
      credentialIssuer: "https://issuer",
      credentialEndpoint: "https://issuer/credential",
      credentialConfigurationsSupported: CredentialMetadata.Mock.sample.credentialConfigurationsSupported,
      display: CredentialMetadata.Mock.sample.display,
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
  }

  private func success() {
    openIDRepositorySpy.fetchMetadataFromReturnValue = metadataResponseMock
    openIDRepositorySpy.fetchCredentialFromRequestBodyAccessTokenFormatPrivateKeyReturnValue = .credential(anyCredential)
    credentialEncryptionContextGeneratorSpy.callAsFunctionForReturnValue = credentialEncryptionContextMock
    deferredCredentialRequestBodyGeneratorSpy.generateTransactionIdCredentialEncryptionContextReturnValue = deferredCredentialRequestBodyMock
  }
}
