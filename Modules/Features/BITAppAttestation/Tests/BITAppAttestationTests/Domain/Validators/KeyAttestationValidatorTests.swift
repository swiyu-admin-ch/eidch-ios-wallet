// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import JOSESwift
import XCTest
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITJWT
@testable import BITTestingCore

final class KeyAttestationValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    validator = KeyAttestationValidator()
    try? createSuccessState()
  }

  func testValidate_parameters_success() async {
    let result = await validator.validate(mockKeyAttestation)

    XCTAssertTrue(result)

    XCTAssertEqual(jwsSignatureValidator.validateDidReceivedArguments?.did, mockKeyAttestation.payload.issuer)
    XCTAssertTrue(appAttestationKeyRepository.getAttestionKeyForCalled)
  }

  func testValidate_count_success() async {
    _ = await validator.validate(mockKeyAttestation)

    XCTAssertEqual(jwsSignatureValidator.validateDidCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.getAttestionKeyForCallsCount, 1)
  }

  func testValidate_unsupportedAlgorithm_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleUnsupportedAlgorithm)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectKid_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleInvalidKid)

    XCTAssertFalse(result)
  }

  func testValidate_notTrustedDid_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleNotTrusted)

    XCTAssertFalse(result)
  }

  func testValidate_invalidIssueAt_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleInvalidIssueAt)

    XCTAssertFalse(result)
  }

  func testValidate_expiredPayload_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleExpired)

    XCTAssertFalse(result)
  }

  func testValidate_unsupportedKeyStorage_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleUnsupportedKeyStorage)

    XCTAssertFalse(result)
  }

  func testValidate_invalidAttestedKey_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleInvalidAttestedKeys)

    XCTAssertFalse(result)
  }

  func testValidate_emptyAttestedKey_returnsFalse() async {
    let result = await validator.validate(KeyAttestationPayload.Mock.sampleEmptyAttestedKeys)

    XCTAssertFalse(result)
  }

  func testValidate_getAttestationKeyFails_returnsFalse() async {
    appAttestationKeyRepository.getAttestionKeyForThrowableError = TestingError.error

    let result = await validator.validate(mockKeyAttestation)

    XCTAssertFalse(result)
  }

  func testValidate_jwsSignatureValidatorReturnsFalse_returnsFalse() async {
    jwsSignatureValidator.validateDidReturnValue = false

    let result = await validator.validate(mockKeyAttestation)

    XCTAssertFalse(result)
  }

  func testValidate_jwsSignatureValidatorThrowsError_returnsFalse() async {
    jwsSignatureValidator.validateDidThrowableError = TestingError.error

    let result = await validator.validate(mockKeyAttestation)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private let mockJWK = JWK(kty: "EC", crv: "P-256", x: "18wHLeIgW9wVN6VD1Txgpqy2LszYkMf6J8njVAibvhM", y: "-V4dS4UaLMgP_4fY4j8ir7cl1TXlFdAgcx55o7TkcSA")
  private var trustedDids: [String]!
  private var supportedAlgorithms: [JWTAlgorithm]!
  private var mockKeyAttestation: KeyAttestation!
  private var validator: KeyAttestationValidator!
  private var jwsSignatureValidator: JWSSignatureValidatorProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!

  private func createSuccessState() throws {
    jwsSignatureValidator.validateDidReturnValue = true
    appAttestationKeyRepository.getAttestionKeyForReturnValue = try ECPublicKey.getSecKey(curve: mockJWK.crv, x: mockJWK.x, y: mockJWK.y)
  }

  private func registerMocks() {
    mockKeyAttestation = KeyAttestationPayload.Mock.sample
    trustedDids = [ "did:tdw:example.com" ]
    supportedAlgorithms = [ .ES256 ]
    jwsSignatureValidator = JWSSignatureValidatorProtocolSpy()
    appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()

    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidator }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.attestationServiceTrustedDids.register { self.trustedDids }
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
