// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITCrypto
import Factory
import XCTest
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// MARK: - CredentialEncryptionContextGeneratorTests

final class CredentialEncryptionContextGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()

    generator = CredentialEncryptionContextGenerator()
  }

  // MARK: - Execute

  func testExecute_missingRequestEncryption_returnsNil() throws {
    let metadata = makeMetadata(requestEncryption: nil, responseEncryption: responseEncryptionMock)

    let context = try generator(for: metadata)

    XCTAssertNil(context)
    XCTAssertEqual(validatorSpy.validateCallsCount, 0)
    XCTAssertEqual(keyRepositorySpy.createUsingCallsCount, 0)
  }

  func testExecute_requestEncryptionWithoutResponseEncryption_returnsContextWithoutKeyPair() throws {
    let metadata = makeMetadata(requestEncryption: requestEncryptionMock, responseEncryption: nil)

    let context = try generator(for: metadata)

    XCTAssertEqual(validatorSpy.validateCallsCount, 1)
    XCTAssertEqual(validatorSpy.validateReceivedMetadata, metadata)
    XCTAssertEqual(context?.issuerPublicKey, issuerPublicKeyMock)
    XCTAssertEqual(context?.credentialRequestEncryptionAlgorithm, requestEncryptionMock.supportedEncryptionAlgorithms.first)
    XCTAssertEqual(context?.credentialRequestEncryptionZipValue, requestEncryptionMock.supportedZipValues?.first)
    XCTAssertNil(context?.credentialResponseEncryptionAlgorithm)
    XCTAssertNil(context?.credentialResponseEncryptionZipValue)
    XCTAssertNil(context?.responseKeyPair)
    XCTAssertEqual(keyRepositorySpy.createUsingCallsCount, 0)
  }

  func testExecute_requestAndResponseEncryption_returnsContextWithKeyPair() throws {
    let metadata = makeMetadata(requestEncryption: requestEncryptionMock, responseEncryption: responseEncryptionMock)

    let context = try generator(for: metadata)

    XCTAssertEqual(context?.credentialResponseEncryptionAlgorithm, responseEncryptionMock.supportedEncryptionAlgorithms.first)
    XCTAssertEqual(context?.credentialResponseEncryptionZipValue, responseEncryptionMock.supportedZipValues?.first)
    XCTAssertEqual(context?.responseKeyPair, keyPairMock)
  }

  func testExecute_validatorThrows_throws() throws {
    validatorSpy.validateThrowableError = TestingError.error
    let metadata = makeMetadata(requestEncryption: requestEncryptionMock, responseEncryption: responseEncryptionMock)

    XCTAssertThrowsError(try generator(for: metadata)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_keyRepositoryThrows_throws() throws {
    keyRepositorySpy.createUsingThrowableError = TestingError.error
    let metadata = makeMetadata(requestEncryption: requestEncryptionMock, responseEncryption: responseEncryptionMock)

    XCTAssertThrowsError(try generator(for: metadata)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let metadataMock = CredentialMetadata.Mock.chasseralIssuer01
  private let issuerPublicKeyMock = CredentialMetadata.Mock.chasseralIssuer01.credentialRequestEncryption!.jwks.keys.first!
  private let keyPairMock = VaultKeyPair.Mock.ES256
  private lazy var requestEncryptionMock = CredentialMetadata.Mock.chasseralIssuer01.credentialRequestEncryption!
  private let responseEncryptionMock = CredentialMetadata.Mock.chasseralIssuer01.credentialResponseEncryption!

  private var generator = CredentialEncryptionContextGenerator()
  private var keyRepositorySpy = CredentialResponseEncryptionKeyRepositoryProtocolSpy()
  private var validatorSpy = CredentialEncryptionValidatorProtocolSpy()

  private func registerMocks() {
    keyRepositorySpy = CredentialResponseEncryptionKeyRepositoryProtocolSpy()
    validatorSpy = CredentialEncryptionValidatorProtocolSpy()

    Container.shared.credentialResponseEncryptionKeyRepository.register { self.keyRepositorySpy }
    Container.shared.credentialEncryptionValidator.register { self.validatorSpy }
  }

  private func success() {
    keyRepositorySpy.createUsingReturnValue = keyPairMock
  }

  private func makeMetadata(
    requestEncryption: CredentialMetadata.CredentialRequestEncryption?,
    responseEncryption: CredentialMetadata.CredentialResponseEncryption?)
    -> CredentialMetadata
  {
    CredentialMetadata(
      credentialIssuer: metadataMock.credentialIssuer,
      credentialEndpoint: metadataMock.credentialEndpoint,
      credentialConfigurationsSupported: metadataMock.credentialConfigurationsSupported,
      display: metadataMock.display,
      credentialRequestEncryption: requestEncryption,
      credentialResponseEncryption: responseEncryption,
      nonceEndpoint: metadataMock.nonceEndpoint,
      deferredCredentialEndpoint: metadataMock.deferredCredentialEndpoint)
  }
}
