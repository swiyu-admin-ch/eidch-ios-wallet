import Factory
import Foundation
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - TokenStatusListValidatorTests

final class TokenStatusListValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    validator = TokenStatusListValidator()

    success()
  }

  func testValidate_validCredential_shouldReturnValid() async {
    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .valid)
  }

  func testValidate_ValidCredential_ArgumentsPassed() async {
    _ = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(jwsMock, tokenStatusListDecoderSpy.decodeIndexReceivedArguments?.jws)
    XCTAssertEqual(Self.indexMock, tokenStatusListDecoderSpy.decodeIndexReceivedArguments?.index)
    XCTAssertEqual(jwsValidatorMock.validateActivationBufferReceivedJws as? JWS, jwsMock)
    XCTAssertEqual(didResolverSpy.getURLFromReceivedDid, Self.issuerMock)
  }

  func testValidate_revokedCredential_shouldReturnRevoked() async {
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(1)

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .revoked)
  }

  func testValidate_suspendedCredential_shouldReturnSuspended() async {
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(2)

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .suspended)
  }

  func testValidate_unsupportedCredentialStatus_shouldReturnUnsupported() async {
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(3)

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unsupported)
  }

  func testValidate_fetchThrowsError_shouldReturnUnknown() async {
    openIdRepositorySpy.fetchCredentialStatusFromThrowableError = TestingError.error

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_statusListWithUntrustedUriHost_shouldReturnUnknown() async {
    let status = VcSdJwtTokenStatus(statusList: VcSdJwtTokenStatus.StatusList(index: Self.indexMock, uri: Self.untrustedStatusListUriMock))

    let result = await validator.validate(status, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_statusListWithInvalidSubject_shouldReturnUnknown() async {
    let payload = TokenStatusList(subject: "invalid", issuedAt: jwsMock.payload.issuedAt, statusList: jwsMock.payload.statusList)
    let jws = JWS(payload: payload, rawPayload: jwsMock.rawPayload, rawJWS: jwsMock.rawJWS, header: jwsMock.header)
    openIdRepositorySpy.fetchCredentialStatusFromReturnValue = jws

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_statusListWithInvalidKidDid_shouldReturnUnknown() async {
    didResolverSpy.getDidFromReturnValue = "invalid"

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_statusListInvalidSignature_shouldReturnUnknown() async {
    jwsValidatorMock.validateThrowableError = TestingError.error

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_validatorThrowsError_shouldReturnUnknown() async {
    jwsValidatorMock.validateThrowableError = TestingError.error

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  // MARK: Private

  // swiftlint:disable all
  private static let baseRegistryDomain = "identifier-reg.example.com"
  private static let statusRegistryDomain = "status-registry.example.com"
  private static let statusListUriMock = "https://\(statusRegistryDomain)/statuslist/example.jwt"
  private static let untrustedStatusListUriMock = "https://untrusted.example.com/statuslist/untrusted.jwt"
  private static let issuerMock = "did:tdw:example"
  private static let indexMock = 285

  private lazy var jwsMock: JWS<TokenStatusList> = {
    let sample = TokenStatusList.Mock.sample
    let payload = TokenStatusList(subject: Self.statusListUriMock, issuedAt: sample.payload.issuedAt, statusList: sample.payload.statusList)
    return JWS(payload: payload, rawPayload: sample.rawPayload, rawJWS: sample.rawJWS, header: sample.header)
  }()

  private var mockStatus = VcSdJwtTokenStatus(statusList: VcSdJwtTokenStatus.StatusList(index: indexMock, uri: statusListUriMock))

  private var openIdRepositorySpy: OpenIDRepositoryProtocolSpy!
  private var tokenStatusListDecoderSpy: TokenStatusListDecoderProtocolSpy!
  private var jwsValidatorMock: JWSValidatorMock<TokenStatusList>!
  private var didResolverSpy: DidResolverHelperProtocolSpy!

  private var validator: TokenStatusListValidator!

  private func registerMocks() {
    openIdRepositorySpy = OpenIDRepositoryProtocolSpy()
    jwsValidatorMock = JWSValidatorMock()
    didResolverSpy = DidResolverHelperProtocolSpy()
    didResolverSpy.getDidFromReturnValue = Self.issuerMock
    didResolverSpy.getURLFromReturnValue = URL(string: "https://\(Self.baseRegistryDomain)/api/v1/did/example")!
    tokenStatusListDecoderSpy = TokenStatusListDecoderProtocolSpy()

    Container.shared.openIDRepository.register { self.openIdRepositorySpy }
    Container.shared.tokenStatusListDecoder.register { self.tokenStatusListDecoderSpy }
    Container.shared.jwsValidator.register { self.jwsValidatorMock }
    Container.shared.didResolverHelper.register { self.didResolverSpy }
    Container.shared.statusRegistryMapping.register { [Self.baseRegistryDomain: Self.statusRegistryDomain] }
    Container.shared.trustEnvironmentDidRegex.register { #/^did:tdw:example$/# }
  }

  private func success() {
    openIdRepositorySpy.fetchCredentialStatusFromReturnValue = jwsMock
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(0)
  }
}
