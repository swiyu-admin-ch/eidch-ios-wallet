// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
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
    createSuccessState()
  }

  func testValidate_parameters_success() async {
    let result = await validator(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertTrue(result)
  }

  func testValidate_count_success() async {
    _ = await validator(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertEqual(jwsValidator.validateActivationBufferCallsCount, 1)
  }

  func testValidate_unsupportedAlgorithm_returnsFalse() async {
    let result = await validator(keyPair: mockKeyPair, with: KeyAttestationJWT.Mock.sampleUnsupportedAlgorithm)

    XCTAssertFalse(result)
  }

  func testValidate_notTrustedDid_returnsFalse() async {
    didResolverSpy.getDidFromReturnValue = "did:tdw:not-trusted"
    let result = await validator(keyPair: mockKeyPair, with: KeyAttestationJWT.Mock.sampleNotTrusted)

    XCTAssertFalse(result)
  }

  func testValidate_missingExpiredAt_returnsFalse() async {
    let result = await validator(keyPair: mockKeyPair, with: KeyAttestationJWT.Mock.sampleMissingExpiredAt)

    XCTAssertFalse(result)
  }

  func testValidate_unsupportedKeyStorage_returnsFalse() async {
    let result = await validator(keyPair: mockKeyPair, with: KeyAttestationJWT.Mock.sampleUnsupportedKeyStorage)

    XCTAssertFalse(result)
  }

  func testValidate_invalidAttestedKey_returnsFalse() async {
    let result = await validator(keyPair: mockKeyPair, with: KeyAttestationJWT.Mock.sampleInvalidAttestedKeys)

    XCTAssertFalse(result)
  }

  func testValidate_emptyAttestedKey_returnsFalse() async {
    let result = await validator(keyPair: mockKeyPair, with: KeyAttestationJWT.Mock.sampleEmptyAttestedKeys)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorThrows_returnsFalse() async {
    jwsValidator.validateThrowableError = TestingError.error

    let result = await validator(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorThrowsError_returnsFalse() async {
    jwsValidator.validateThrowableError = TestingError.error

    let result = await validator(keyPair: mockKeyPair, with: mockKeyAttestation)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private var trustedDids: [String]!
  private var mockKeyAttestation: KeyAttestation!
  private var mockKeyPair: VaultKeyPair!
  private var validator: KeyAttestationValidator!
  private var jwsValidator: JWSValidatorMock<KeyAttestationJWT>!
  private var didResolverSpy: DidResolverHelperProtocolSpy!
  private let mockSupportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel] = [.iso18045High]

  private func createSuccessState() {
    mockKeyPair = VaultKeyPair.Mock.attestedKey
    didResolverSpy.getDidFromReturnValue = "did:tdw:example.com"
  }

  private func registerMocks() {
    mockKeyAttestation = KeyAttestationJWT.Mock.sample
    trustedDids = [ "did:tdw:example.com" ]
    jwsValidator = JWSValidatorMock()
    didResolverSpy = DidResolverHelperProtocolSpy()

    Container.shared.jwsValidator.register { self.jwsValidator }
    Container.shared.didResolverHelper.register { self.didResolverSpy }
    Container.shared.attestationServiceTrustedDids.register { self.trustedDids }
    Container.shared.supportedKeyStorageSecurityLevel.register { self.mockSupportedKeyStorageSecurityLevel }
  }

}
