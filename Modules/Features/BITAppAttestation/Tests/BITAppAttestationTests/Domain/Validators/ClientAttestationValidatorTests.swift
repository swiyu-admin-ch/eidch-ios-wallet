// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITAppInfo
@testable import BITCore
@testable import BITCrypto
@testable import BITJsonCanonicalizer
@testable import BITJWT
@testable import BITTestingCore
@testable import BITVault

final class ClientAttestationValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    validator = ClientAttestationValidator()
    createSuccessState()
  }

  func testValidate_parameters_success() async {
    let result = await validator(mockClientAttestation)

    XCTAssertTrue(result)

    XCTAssertEqual(appAttestationKeyRepository.getForReceivedType, .client)
    XCTAssertTrue(appIdentifierRepository.getCalled)
  }

  func testValidate_count_success() async {
    _ = await validator(mockClientAttestation)

    XCTAssertEqual(jwsValidator.validateActivationBufferCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.getForCallsCount, 1)
    XCTAssertEqual(appIdentifierRepository.getCallsCount, 1)
  }

  func testValidate_unsupportedAlgorithm_returnsFalse() async {
    let result = await validator(ClientAttestationJWT.Mock.sampleUnsupportedAlgorithm)

    XCTAssertFalse(result)
  }

  func testValidate_notTrustedIssuerWithTrustedKid_returnsTrue() async throws {
    let key = SecKeyTestsHelper.createStaticPrivateKey()
    appAttestationKeyRepository.getForReturnValue = VaultKeyPair(identifier: UUID().uuidString, privateKey: key, algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
    jsonCanonicalizer.canonicalizeDataReturnValue = try XCTUnwrap(Data(base64URLEncoded: "eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6InFNTGxPUjVYVjgtQ1dTQ045UzNIUU9mUG1ZTWhrWnhLMUZKT2Jpa3pZZTgiLCJ5Ijoidm1OMS0yS2dQSUFWM1Z1cmFYWmhBdWhyNnJyMjdITDNtUExTYVRvLUhkYyJ9"))

    let result = await validator(ClientAttestationJWT.Mock.sampleNotTrusted)

    XCTAssertTrue(result)
  }

  func testValidate_missingExpiredAt_returnsFalse() async {
    let result = await validator(ClientAttestationJWT.Mock.sampleMissingExpiredAt)

    XCTAssertFalse(result)
  }

  func testValidate_missingActivatedAt_returnsFalse() async {
    let result = await validator(ClientAttestationJWT.Mock.sampleMissingActivatedAt)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectWalletName_returnsFalse() async {
    let result = await validator(ClientAttestationJWT.Mock.sampleIncorrectName)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectBindingKey_returnsFalse() async {
    let result = await validator(ClientAttestationJWT.Mock.sampleIncorrectBindingKey)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectKid_returnsFalse() async {
    didResolverSpy.getDidFromReturnValue = "did:tdw:mock.com"
    let result = await validator(ClientAttestationJWT.Mock.sampleIncorrectKid)

    XCTAssertFalse(result)
  }

  func testValidate_incorrectSub_returnsFalse() async {
    let result = await validator(ClientAttestationJWT.Mock.sampleIncorrectSub)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorThrows_returnsFalse() async {
    jwsValidator.validateThrowableError = TestingError.error

    let result = await validator(mockClientAttestation)

    XCTAssertFalse(result)
  }

  func testValidate_appIdentifierRepositoryThrows_returnsFalse() async {
    appIdentifierRepository.getThrowableError = TestingError.error

    let result = await validator(mockClientAttestation)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorThrowsError_returnsFalse() async {
    jwsValidator.validateThrowableError = TestingError.error

    let result = await validator(mockClientAttestation)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private var trustedDids: [String]!
  private var mockClientAttestation: ClientAttestation!
  private var validator: ClientAttestationValidator!
  private var jwsValidator: JWSValidatorMock<ClientAttestationJWT>!
  private var didResolverSpy: DidResolverHelperProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var jsonCanonicalizer: JsonCanonicalizerProtocolSpy!
  private var appIdentifierRepository: AppIdentifierRepositoryProtocolSpy!

  private func createSuccessState() {
    appAttestationKeyRepository.getForReturnValue = VaultKeyPair.Mock.attestedKey
    jsonCanonicalizer.canonicalizeDataReturnValue = Data(base64URLEncoded: "eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6IjE4d0hMZUlnVzl3Vk42VkQxVHhncHF5MkxzellrTWY2SjhualZBaWJ2aE0iLCJ5IjoiLVY0ZFM0VWFMTWdQXzRmWTRqOGlyN2NsMVRYbEZkQWdjeDU1bzdUa2NTQSJ9")!
    appIdentifierRepository.getReturnValue = "ch.mock.identifier"
    didResolverSpy.getDidFromReturnValue = "did:tdw:example.com"
  }

  private func registerMocks() {
    mockClientAttestation = ClientAttestationJWT.Mock.sample
    trustedDids = [ "did:tdw:example.com" ]
    jwsValidator = JWSValidatorMock()
    didResolverSpy = DidResolverHelperProtocolSpy()
    appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    jsonCanonicalizer = JsonCanonicalizerProtocolSpy()
    appIdentifierRepository = AppIdentifierRepositoryProtocolSpy()

    Container.shared.jwsValidator.register { self.jwsValidator }
    Container.shared.didResolverHelper.register { self.didResolverSpy }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.attestationServiceTrustedDids.register { self.trustedDids }
    Container.shared.jsonCanonicalizer.register { self.jsonCanonicalizer }
    Container.shared.appIdentifierRepository.register { self.appIdentifierRepository }
  }

}
