// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import JOSESwift
import XCTest
@testable import BITCrypto
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

class CredentialRequestBodyGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()
    generator = CredentialRequestBodyGenerator()
  }

  func testGenerate_withoutEncryptionContext_generatesJSON() throws {
    let body = try generator.generate(for: contextNoCredentialEncryptionMock, proofs: proofsMock)

    guard case .json(let request) = body else {
      XCTFail("Expected json request body")
      return
    }

    XCTAssertEqual(request.credentialConfigurationId, contextNoCredentialEncryptionMock.credentialConfigurationId)
    XCTAssertEqual(request.proofs?.jwt, proofsMock.jwt)
    XCTAssertNil(request.credentialResponseEncryption)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmCallsCount, 0)
  }

  func testGenerate_withEncryptionContext_generatesJWE() throws {
    let body = try generator.generate(for: contextCredentialEncryptionMock, proofs: proofsMock)

    guard case .jwe(let token) = body else {
      XCTFail("Expected jwe request body")
      return
    }

    XCTAssertEqual(token, jweMock)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmCallsCount, 1)

    let encryptionContext = contextCredentialEncryptionMock.credentialEncryptionContext

    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.publicKey, encryptionContext?.issuerPublicKey)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.encryptionAlgorithm, encryptionContext?.credentialRequestEncryptionAlgorithm)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.compressionAlgorithm, encryptionContext?.credentialRequestEncryptionZipValue)
  }

  func testGenerate_encrypterThrows_throwsError() throws {
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: contextCredentialEncryptionMock, proofs: nil)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let jwtMock = "jwt"

  private let contextNoCredentialEncryptionMock = FetchCredentialContext.Mock.sampleVcSdJwt
  private let contextCredentialEncryptionMock = FetchCredentialContext.Mock.sampleCredentialEncryption
  private let issuerPublicKey = JWK.Mock.validSample
  private let responseKeyPair = VaultKeyPair.Mock.ES256
  private let proofsMock = CredentialRequest.Proofs(jwt: [jwtMock])

  private var generator = CredentialRequestBodyGenerator()
  private var jweEncrypterSpy = JWEEncrypterProtocolSpy()
  private var jweMock = JWE.Mock.sampleCredentialRequest.compactSerializedString

  private func registerMocks() {
    jweEncrypterSpy = JWEEncrypterProtocolSpy()
    Container.shared.jweEncrypter.register { self.jweEncrypterSpy }
  }

  private func success() {
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReturnValue = jweMock
  }
}
