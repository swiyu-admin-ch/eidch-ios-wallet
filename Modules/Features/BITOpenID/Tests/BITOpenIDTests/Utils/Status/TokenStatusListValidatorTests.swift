import Factory
import Foundation
import XCTest
@testable import BITAnyCredentialFormatMocks
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// MARK: - TokenStatusListValidatorTests

final class TokenStatusListValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    openIdRepositorySpy = OpenIDRepositoryProtocolSpy()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()
    tokenStatusListDecoderSpy = TokenStatusListDecoderProtocolSpy()

    Container.shared.openIDRepository.register { self.openIdRepositorySpy }
    Container.shared.tokenStatusListDecoder.register { self.tokenStatusListDecoderSpy }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }

    validator = TokenStatusListValidator()

    success()
  }

  func testValidate_ValidCredential_ShouldReturnValid() async throws {
    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .valid)
  }

  func testValidate_ValidCredential_ArgumentsPassed() async throws {
    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(jwsMock, tokenStatusListDecoderSpy.decodeIndexReceivedArguments?.jws)
    XCTAssertEqual(Self.indexMock, tokenStatusListDecoderSpy.decodeIndexReceivedArguments?.index)
    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedJws as? JWS, jwsMock)
    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedDid, jwsMock.payload.issuer)
  }

  func testValidate_RevokedCredential_ShouldReturnRevoked() async throws {
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(1)

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .revoked)
  }

  func testValidate_SuspendedCredential_ShouldReturnSuspended() async throws {
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(2)

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .suspended)
  }

  func testValidate_UnsupportedCredentialStatus_ShouldReturnUnsupported() async throws {
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(3)

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unsupported)
  }

  func testValidate_FetchThrowsError_ShouldReturnUnknown() async throws {
    openIdRepositorySpy.fetchCredentialStatusFromThrowableError = TestingError.error

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_StatusListWithInvalidSubject_ShouldReturnUnknown() async throws {
    let payload = TokenStatusList(issuer: jwsMock.payload.issuer, subject: "invalid", issuedAt: jwsMock.payload.issuedAt, statusList: jwsMock.payload.statusList)
    let jws = JWS(payload: payload, rawJWS: jwsMock.rawJWS, rawPayload: jwsMock.rawPayload, header: jwsMock.header)
    openIdRepositorySpy.fetchCredentialStatusFromReturnValue = jws

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_StatusListWithInvalidIssuer_ShouldReturnUnknown() async throws {
    let payload = TokenStatusList(issuer: "invalid", subject: jwsMock.payload.subject, issuedAt: jwsMock.payload.issuedAt, statusList: jwsMock.payload.statusList)
    let jws = JWS(payload: payload, rawJWS: jwsMock.rawJWS, rawPayload: jwsMock.rawPayload, header: jwsMock.header)
    openIdRepositorySpy.fetchCredentialStatusFromReturnValue = jws

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_StatusListInvalidSignature_ShouldReturnUnknown() async throws {
    jwsSignatureValidatorMock.validateJwsDidReturnValue = false

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_StatusListExpired_ShouldReturnUnknown() async throws {
    openIdRepositorySpy.fetchCredentialStatusFromReturnValue = TokenStatusList.Mock.expired

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  func testValidate_ValidatorThrowsError_ShouldReturnUnknown() async throws {
    jwsSignatureValidatorMock.validateJwsDidThrowableError = TestingError.error

    let result = await validator.validate(mockStatus, issuer: Self.issuerMock)

    XCTAssertEqual(result, .unknown)
  }

  // MARK: Private

  // swiftlint:disable all
  private static let statusListUriMock = "https://example.com/statuslist/example.jwt"
  private static let issuerMock = "did:tdw:example"
  private static let indexMock = 285

  private let jwsMock = TokenStatusList.Mock.sample
  private var mockStatus = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: indexMock, uri: statusListUriMock))

  private var openIdRepositorySpy: OpenIDRepositoryProtocolSpy!
  private var tokenStatusListDecoderSpy: TokenStatusListDecoderProtocolSpy!
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock!

  private var validator: TokenStatusListValidator!

  private func success() {
    openIdRepositorySpy.fetchCredentialStatusFromReturnValue = jwsMock
    jwsSignatureValidatorMock.validateJwsDidReturnValue = true
    tokenStatusListDecoderSpy.decodeIndexReturnValue = StatusCode(0)
  }
  // swiftlint:enable all
}
