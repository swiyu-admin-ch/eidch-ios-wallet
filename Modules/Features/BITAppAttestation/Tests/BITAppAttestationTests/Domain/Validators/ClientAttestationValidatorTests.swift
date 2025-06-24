// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import JOSESwift
import XCTest
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITJsonCanonicalizer
@testable import BITJWT
@testable import BITTestingCore

final class ClientAttestationValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    validator = ClientAttestationValidator()
    try? createSuccessState()
  }

  func testValidate_parameters_success() async {
    let result = await validator.validate(mockClientAttestation)

    XCTAssertTrue(result)

    XCTAssertEqual(jwsSignatureValidator.validateDidReceivedArguments?.did, mockClientAttestation.payload.issuer)
    XCTAssertEqual(appAttestationKeyRepository.getAttestionKeyForReceivedAttestKey, .clientAttestation)
  }

  func testValidate_count_success() async {
    _ = await validator.validate(mockClientAttestation)

    XCTAssertEqual(jwsSignatureValidator.validateDidCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.getAttestionKeyForCallsCount, 1)
  }

  func testValidate_unsupportedAlgorithm_returnsFalse() async {
    let result = await validator.validate(ClientAttestationPayload.Mock.sampleUnsupportedAlgorithm)

    XCTAssertFalse(result)
  }

  func testValidate_expiredPayload_returnsFalse() async {
    let result = await validator.validate(ClientAttestationPayload.Mock.sampleExpired)

    XCTAssertFalse(result)
  }

  func testValidate_notTrustedDid_returnsFalse() async {
    let result = await validator.validate(ClientAttestationPayload.Mock.sampleNotTrusted)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectWalletName_returnsFalse() async {
    let result = await validator.validate(ClientAttestationPayload.Mock.sampleIncorrectName)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectBindingKey_returnsFalse() async {
    let result = await validator.validate(ClientAttestationPayload.Mock.sampleIncorrectBindingKey)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectKid_returnsFalse() async {
    let result = await validator.validate(ClientAttestationPayload.Mock.sampleIncorrectKid)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectSub_returnsFalse() async {
    let result = await validator.validate(ClientAttestationPayload.Mock.sampleIncorrectSub)

    XCTAssertFalse(result)
  }

  func testValidate_jwsSignatureValidatorReturnsFalse_returnsFalse() async {
    jwsSignatureValidator.validateDidReturnValue = false

    let result = await validator.validate(mockClientAttestation)

    XCTAssertFalse(result)
  }

  func testValidate_jwsSignatureValidatorThrowsError_returnsFalse() async {
    jwsSignatureValidator.validateDidThrowableError = TestingError.error

    let result = await validator.validate(mockClientAttestation)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private let mockJWK = JWK(kty: "EC", crv: "P-256", x: "18wHLeIgW9wVN6VD1Txgpqy2LszYkMf6J8njVAibvhM", y: "-V4dS4UaLMgP_4fY4j8ir7cl1TXlFdAgcx55o7TkcSA")
  private var trustedDids: [String]!
  private var supportedAlgorithms: [JWTAlgorithm]!
  private var mockClientAttestation: ClientAttestation!
  private var validator: ClientAttestationValidator!
  private var jwsSignatureValidator: JWSSignatureValidatorProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var jsonCanonicalizer: JsonCanonicalizerProtocolSpy!

  private func createSuccessState() throws {
    jwsSignatureValidator.validateDidReturnValue = true
    appAttestationKeyRepository.getAttestionKeyForReturnValue = try ECPublicKey.getSecKey(curve: mockJWK.crv, x: mockJWK.x, y: mockJWK.y)
    jsonCanonicalizer.canonicalizeDataReturnValue = Data(base64URLEncoded: "eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6IjE4d0hMZUlnVzl3Vk42VkQxVHhncHF5MkxzellrTWY2SjhualZBaWJ2aE0iLCJ5IjoiLVY0ZFM0VWFMTWdQXzRmWTRqOGlyN2NsMVRYbEZkQWdjeDU1bzdUa2NTQSJ9")!
  }

  private func registerMocks() {
    mockClientAttestation = ClientAttestationPayload.Mock.sample
    trustedDids = [ "did:tdw:example.com" ]
    supportedAlgorithms = [ .ES256 ]
    jwsSignatureValidator = JWSSignatureValidatorProtocolSpy()
    appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    jsonCanonicalizer = JsonCanonicalizerProtocolSpy()

    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidator }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.attestationServiceTrustedDids.register { self.trustedDids }
    Container.shared.jsonCanonicalizer.register { self.jsonCanonicalizer }
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
