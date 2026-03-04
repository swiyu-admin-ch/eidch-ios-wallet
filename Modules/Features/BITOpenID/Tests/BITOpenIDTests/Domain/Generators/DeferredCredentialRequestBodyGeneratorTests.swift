// swiftlint:disable implicitly_unwrapped_optional
import Factory
import JOSESwift
import XCTest
@testable import BITCrypto
@testable import BITOpenID
@testable import BITTestingCore

class DeferredCredentialRequestBodyGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()
    generator = DeferredCredentialRequestBodyGenerator()
  }

  func testGenerate_withoutEncryptionContext_generatesJSON() throws {
    let body = try generator.generate(transactionId: Self.transactionIdMock, credentialEncryptionContext: nil)

    guard case .json(let request) = body else {
      XCTFail("Expected json request body")
      return
    }

    XCTAssertEqual(request.transactionId, Self.transactionIdMock)
    XCTAssertNil(request.credentialResponseEncryption)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmCallsCount, 0)
  }

  func testGenerate_withEncryptionContext_generatesJWE() throws {
    let body = try generator.generate(transactionId: Self.transactionIdMock, credentialEncryptionContext: encryptionContextMock)

    guard case .jwe(let token) = body else {
      XCTFail("Expected jwe request body")
      return
    }

    XCTAssertEqual(token, jweMock)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmCallsCount, 1)

    guard let arguments = jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments else {
      XCTFail("Expected encrypter arguments")
      return
    }

    XCTAssertEqual(arguments.publicKey, encryptionContextMock?.issuerPublicKey)
    XCTAssertEqual(arguments.encryptionAlgorithm, encryptionContextMock?.credentialRequestEncryptionAlgorithm)
    XCTAssertEqual(arguments.compressionAlgorithm, encryptionContextMock?.credentialRequestEncryptionZipValue)
  }

  func testGenerate_encrypterThrows_throwsError() throws {
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(transactionId: Self.transactionIdMock, credentialEncryptionContext: encryptionContextMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let transactionIdMock = "transactionId"

  private let encryptionContextMock = FetchCredentialContext.Mock.sampleCredentialEncryption.credentialEncryptionContext
  private let issuerPublicKey = JWK.Mock.validSample

  private var generator = DeferredCredentialRequestBodyGenerator()
  private var jweEncrypterSpy = JWEEncrypterProtocolSpy()
  private var jweMock = JWE.Mock.sampleCredentialRequestDeferred.compactSerializedString

  private func registerMocks() {
    jweEncrypterSpy = JWEEncrypterProtocolSpy()
    Container.shared.jweEncrypter.register { self.jweEncrypterSpy }
  }

  private func success() {
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReturnValue = jweMock
  }
}
