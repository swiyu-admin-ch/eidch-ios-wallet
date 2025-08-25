// swiftlint:disable implicitly_unwrapped_optional

import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class ValidateTrustStatementUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    useCase = ValidateTrustStatementUseCase()
    createSuccessState()
  }

  func testExecute_valid_returnsTrue() async throws {
    let result = await useCase.execute(trustStatementMock, for: subjectMock)

    XCTAssertTrue(result)
  }

  func testExecute_valid_argumentsPassed() async throws {
    _ = await useCase.execute(trustStatementMock, for: subjectMock)

    XCTAssertEqual(trustRegistryRepositorySpy.getTrustedDidsCallsCount, 1)

    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedJws?.rawJWS, trustStatementMock.rawJWS)
    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedDid, trustStatementMock.payload.issuer)

    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerCallsCount, 1)
    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.anyStatus.type, trustStatementMock.payload.statusList.type)
    XCTAssertEqual(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.issuer, trustStatementMock.payload.issuer)
  }

  func testExecute_notTrustedDid_returnsFalse() async throws {
    trustRegistryRepositorySpy.getTrustedDidsReturnValue = ["other"]

    let result = await useCase.execute(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testExecute_wrongSubject_returnsFalse() async throws {
    let result = await useCase.execute(TrustStatementPayload.Mock.wrongSubject, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testExecute_wrongAlgorithm_returnsFalse() async throws {
    let result = await useCase.execute(TrustStatementPayload.Mock.wrongAlgorithm, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testExecute_notYetValid_returnsFalse() async throws {
    let result = await useCase.execute(TrustStatementPayload.Mock.notYetValid, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testExecute_expired_returnsFalse() async throws {
    let result = await useCase.execute(TrustStatementPayload.Mock.expired, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testExecute_invalidJWSSignature_returnsFalse() async throws {
    jwsSignatureValidatorMock.validateJwsDidReturnValue = false

    let result = await useCase.execute(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testExecute_jwsSignatureValidatorError_returnsFalse() async throws {
    jwsSignatureValidatorMock.validateJwsDidThrowableError = TestingError.error

    let result = await useCase.execute(trustStatementMock, for: subjectMock)

    XCTAssertFalse(result)
  }

  func testExecute_notValidStatus_returnsFalse() async throws {
    for status in [VcStatus.revoked, VcStatus.suspended, VcStatus.unknown, VcStatus.unsupported] {
      tokenStatusListValidatorSpy.validateIssuerReturnValue = status

      let result = await useCase.execute(trustStatementMock, for: subjectMock)

      XCTAssertFalse(result, "Status: \(status)")
    }
  }

  // MARK: Private

  private let trustStatementMock: TrustStatement = TrustStatementPayload.Mock.validSample
  private let subjectMock = "subject"

  private var trustRegistryRepositorySpy: TrustRegistryRepositoryProtocolSpy!
  private var jwsSignatureValidatorMock = JWSSignatureValidatorMock()
  private var tokenStatusListValidatorSpy: AnyStatusCheckValidatorProtocolSpy!

  private var useCase: ValidateTrustStatementUseCase!

  private let trustedDids: [String] = [
    "did:tdw:another-example",
    TrustStatementPayload.Mock.validSamplePayload.issuer,
  ]

  private func registerMocks() {
    trustRegistryRepositorySpy = TrustRegistryRepositoryProtocolSpy()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()
    tokenStatusListValidatorSpy = AnyStatusCheckValidatorProtocolSpy()

    Container.shared.trustRegistryRepository.register { self.trustRegistryRepositorySpy }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
    Container.shared.tokenStatusListValidator.register { self.tokenStatusListValidatorSpy }
  }

  private func createSuccessState() {
    trustRegistryRepositorySpy.getTrustedDidsReturnValue = trustedDids
    jwsSignatureValidatorMock.validateJwsDidReturnValue = true
    tokenStatusListValidatorSpy.validateIssuerReturnValue = .valid
  }
}

// swiftlint:enable all
