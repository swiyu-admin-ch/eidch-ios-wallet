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

  func testValidate_valid_returnsTrue() async throws {
    let result = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertTrue(result)
  }

  func testValidate_valid_argumentsPassed() async throws {
    _ = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertEqual(trustRegistryRepositorySpy.getTrustedDidsCallsCount, 1)

    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferReceivedJws?.rawJWS, trustStatementMock.rawJWS)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferReceivedDid, trustStatementMock.payload.issuer)

    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerCallsCount, 1)
    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.anyStatus.type, trustStatementMock.payload.statusList.type)
    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.issuer, trustStatementMock.payload.issuer)
  }

  func testValidate_invalidVct_returnsFalse() async throws {
    let trustStatement = TrustStatementPayload.Mock.invalidVct

    let result = await validator.validate(trustStatement, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_wrongSubject_returnsFalse() async throws {
    let trustStatement = TrustStatementPayload.Mock.wrongSubject

    let result = await validator.validate(trustStatement, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_notTrustedDid_returnsFalse() async throws {
    trustRegistryRepositorySpy.getTrustedDidsReturnValue = ["other"]

    let result = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_wrongAlgorithm_returnsFalse() async throws {
    let trustStatement = TrustStatementPayload.Mock.wrongAlgorithm

    let result = await validator.validate(trustStatement, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorReturnsFalse_returnsFalse() async throws {
    jwsValidatorMock.validateIssuerDidActivationBufferReturnValue = false

    let result = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_jwsValidatorError_returnsFalse() async throws {
    jwsValidatorMock.validateIssuerDidActivationBufferThrowableError = TestingError.error

    let result = await validator.validate(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testValidate_notValidStatus_returnsFalse() async throws {
    for status in [VcStatus.revoked, VcStatus.suspended, VcStatus.unknown, VcStatus.unsupported] {
      tokenStatusListValidatorSpy.validateIssuerReturnValue = status

      let result = await validator.validate(trustStatementMock, for: subjectMock)

      XCTAssertFalse(result, "Status: \(status)")
    }
  }

  // MARK: Private

  private let trustStatementMock: TrustStatement = TrustStatementPayload.Mock.validSample
  private let subjectMock = "subject"
  private let trustedDids: [String] = [
    "did:tdw:another-example",
    "issuer",
  ]

  private var trustRegistryRepositorySpy: TrustRegistryRepositoryProtocolSpy!
  private var jwsValidatorMock: JWSValidatorMock<TrustStatementPayload>!
  private var tokenStatusListValidatorSpy: AnyStatusCheckValidatorProtocolSpy!

  private var validator: TrustStatementValidator!

  private func registerMocks() {
    trustRegistryRepositorySpy = TrustRegistryRepositoryProtocolSpy()
    jwsValidatorMock = JWSValidatorMock()
    tokenStatusListValidatorSpy = AnyStatusCheckValidatorProtocolSpy()

    Container.shared.trustRegistryRepository.register { self.trustRegistryRepositorySpy }
    Container.shared.jwsValidator.register { self.jwsValidatorMock }
    Container.shared.tokenStatusListValidator.register { self.tokenStatusListValidatorSpy }
  }

  private func createSuccessState() {
    trustRegistryRepositorySpy.getTrustedDidsReturnValue = trustedDids
    jwsValidatorMock.validateIssuerDidActivationBufferReturnValue = true
    tokenStatusListValidatorSpy.validateIssuerReturnValue = .valid
  }
}

// swiftlint:enable all
