// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import JOSESwift
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
    try? createSuccessState()
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

  func testValidate_notTrustedIssuerWithTrustedKid_returnsTrue() async {
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

  private let mockJWK = JWK(kty: "EC", crv: "P-256", x: "18wHLeIgW9wVN6VD1Txgpqy2LszYkMf6J8njVAibvhM", y: "-V4dS4UaLMgP_4fY4j8ir7cl1TXlFdAgcx55o7TkcSA")
  private var trustedDids: [String]!
  private var supportedAlgorithms: [JWTAlgorithm]!
  private var mockClientAttestation: ClientAttestation!
  private var validator: ClientAttestationValidator!
  private var jwsValidator: JWSValidatorMock<ClientAttestationJWT>!
  private var didResolverSpy: DidResolverHelperProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var jsonCanonicalizer: JsonCanonicalizerProtocolSpy!
  private var appIdentifierRepository: AppIdentifierRepositoryProtocolSpy!

  private func createSuccessState() throws {
    let key = try ECPublicKey.getSecKey(curve: mockJWK.crv, x: mockJWK.x, y: mockJWK.y)!
    let keyPair = VaultKeyPair(identifier: UUID().uuidString, privateKey: key, algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
    appAttestationKeyRepository.getForReturnValue = keyPair
    jsonCanonicalizer.canonicalizeDataReturnValue = Data(base64URLEncoded: "eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6IjE4d0hMZUlnVzl3Vk42VkQxVHhncHF5MkxzellrTWY2SjhualZBaWJ2aE0iLCJ5IjoiLVY0ZFM0VWFMTWdQXzRmWTRqOGlyN2NsMVRYbEZkQWdjeDU1bzdUa2NTQSJ9")!
    appIdentifierRepository.getReturnValue = "ch.mock.identifier"
    didResolverSpy.getDidFromReturnValue = "did:tdw:example.com"
  }

  private func registerMocks() {
    mockClientAttestation = ClientAttestationJWT.Mock.sample
    trustedDids = [ "did:tdw:example.com" ]
    supportedAlgorithms = [ .ES256 ]
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
