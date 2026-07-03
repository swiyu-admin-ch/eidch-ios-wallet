// swiftlint:disable implicitly_unwrapped_optional

import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class TrustStatementValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    validator = TrustStatementValidator()
    createSuccessState()
  }

  func testValidate_valid_returnsTrue() async {
    let result = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertTrue(result)
  }

  func testValidate_valid_argumentsPassed() async {
    _ = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertEqual(jwsValidatorMock.validateActivationBufferCallsCount, 1)
    XCTAssertEqual(jwsValidatorMock.validateActivationBufferReceivedJws?.rawJWS, trustStatementMock.rawJWS)

    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerCallsCount, 1)
    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.anyStatus.type, trustStatementMock.payload.statusList.type)
    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.issuer, issuerMock)
  }

  func testValidate_wrongSubject_returnsFalse() async {
    let trustStatement = IdentityTrustStatementJWT.Mock.wrongSubject

    let result = await validator.validate(trustStatement, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_wrongAlgorithm_returnsFalse() async {
    let trustStatement = IdentityTrustStatementJWT.Mock.wrongAlgorithm

    let result = await validator.validate(trustStatement, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorReturnsFalse_returnsFalse() async {
    jwsValidatorMock.validateThrowableError = TestingError.error

    let result = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorError_returnsFalse() async {
    jwsValidatorMock.validateThrowableError = TestingError.error

    let result = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_notValidStatus_returnsFalse() async {
    for status in [VcStatus.revoked, VcStatus.suspended, VcStatus.unknown, VcStatus.unsupported] {
      tokenStatusListValidatorSpy.validateIssuerReturnValue = status

      let result = await validator.validate(trustStatementMock, for: subjectMock)

      XCTAssertFalse(result, "Status: \(status)")
    }
  }

  // MARK: Private

  private let trustStatementMock = IdentityTrustStatementJWT.Mock.validSample
  private let subjectMock = "subject"
  private let issuerMock = "did"

  private var jwsValidatorMock: JWSValidatorMock<IdentityTrustStatementJWT>!
  private var didResolverSpy: DidResolverHelperProtocolSpy!
  private var tokenStatusListValidatorSpy: AnyStatusCheckValidatorProtocolSpy!

  private var validator: TrustStatementValidator!

  private func registerMocks() {
    jwsValidatorMock = JWSValidatorMock()
    didResolverSpy = DidResolverHelperProtocolSpy()
    tokenStatusListValidatorSpy = AnyStatusCheckValidatorProtocolSpy()

    Container.shared.jwsValidator.register { self.jwsValidatorMock }
    Container.shared.didResolverHelper.register { self.didResolverSpy }
    Container.shared.tokenStatusListValidator.register { self.tokenStatusListValidatorSpy }
  }

  private func createSuccessState() {
    tokenStatusListValidatorSpy.validateIssuerReturnValue = .valid
    didResolverSpy.getDidFromReturnValue = issuerMock
  }
}
