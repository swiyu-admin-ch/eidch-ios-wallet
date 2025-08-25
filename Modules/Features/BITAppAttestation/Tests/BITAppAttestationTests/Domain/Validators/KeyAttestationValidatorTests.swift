// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import JOSESwift
import XCTest
@testable import BITAppAttestation
@testable import BITCore
@testable import BITCrypto
@testable import BITJWT
@testable import BITTestingCore
@testable import BITVault

final class KeyAttestationValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    validator = KeyAttestationValidator()
    try? createSuccessState()
  }

  func testValidate_parameters_success() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertTrue(result)

    XCTAssertEqual(jwsSignatureValidator.validateDidReceivedArguments?.did, mockKeyAttestation.payload.issuer)
  }

  func testValidate_count_success() async {
    _ = await validator.validate(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertEqual(jwsSignatureValidator.validateDidCallsCount, 1)
  }

  func testValidate_unsupportedAlgorithm_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleUnsupportedAlgorithm)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectKid_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleInvalidKid)

    XCTAssertFalse(result)
  }

  func testValidate_notTrustedDid_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleNotTrusted)

    XCTAssertFalse(result)
  }

  func testValidate_invalidIssueAt_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleInvalidIssueAt)

    XCTAssertFalse(result)
  }

  func testValidate_expiredPayload_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleExpired)

    XCTAssertFalse(result)
  }

  func testValidate_unsupportedKeyStorage_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleUnsupportedKeyStorage)

    XCTAssertFalse(result)
  }

  func testValidate_invalidAttestedKey_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleInvalidAttestedKeys)

    XCTAssertFalse(result)
  }

  func testValidate_emptyAttestedKey_returnsFalse() async {
    let result = await validator.validate(keyPair: mockKeyPair, with: KeyAttestationPayload.Mock.sampleEmptyAttestedKeys)

    XCTAssertFalse(result)
  }

  func testValidate_jwsSignatureValidatorReturnsFalse_returnsFalse() async {
    jwsSignatureValidator.validateDidReturnValue = false

    let result = await validator.validate(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertFalse(result)
  }

  func testValidate_jwsSignatureValidatorThrowsError_returnsFalse() async {
    jwsSignatureValidator.validateDidThrowableError = TestingError.error

    let result = await validator.validate(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private let mockJWK = JWK(kty: "EC", crv: "P-256", x: "18wHLeIgW9wVN6VD1Txgpqy2LszYkMf6J8njVAibvhM", y: "-V4dS4UaLMgP_4fY4j8ir7cl1TXlFdAgcx55o7TkcSA")
  private var trustedDids: [String]!
  private var supportedAlgorithms: [JWTAlgorithm]!
  private var mockKeyAttestation: KeyAttestation!
  private var mockKeyPair: VaultKeyPair!
  private var validator: KeyAttestationValidator!
  private var jwsSignatureValidator: JWSSignatureValidatorProtocolSpy!
  private let mockSupportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel] = [.iso18045High]

  private func createSuccessState() throws {
    jwsSignatureValidator.validateDidReturnValue = true
    let key = try ECPublicKey.getSecKey(curve: mockJWK.crv, x: mockJWK.x, y: mockJWK.y)!
    let keyPair = VaultKeyPair(identifier: UUID().uuidString, privateKey: key, algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
    mockKeyPair = keyPair
  }

  private func registerMocks() {
    mockKeyAttestation = KeyAttestationPayload.Mock.sample
    trustedDids = [ "did:tdw:example.com" ]
    supportedAlgorithms = [ .ES256 ]
    jwsSignatureValidator = JWSSignatureValidatorProtocolSpy()

    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidator }
    Container.shared.attestationServiceTrustedDids.register { self.trustedDids }
    Container.shared.supportedKeyStorageSecurityLevel.register { self.mockSupportedKeyStorageSecurityLevel }
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
