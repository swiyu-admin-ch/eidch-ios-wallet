import BITCore
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

final class CheckAndUpdateCredentialStatusUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    anyCredentialSpy = AnyCredentialSpy()
    createAnyCredentialSpy = CreateAnyCredentialUseCaseProtocolSpy()
    credentialRepository = CredentialRepositoryProcotolSpy()
    validatorSpy = AnyStatusCheckValidatorProtocolSpy()

    Container.shared.createAnyCredentialUseCase.register { self.createAnyCredentialSpy }
    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.statusValidators.register { [AnyStatusType.tokenStatusList: self.validatorSpy] }
    Container.shared.dateBuffer.register { Self.buffer }

    useCase = CheckAndUpdateCredentialStatusUseCase()

    success()
  }

  func testCheckCredentialStatus_valid() async throws {
    success(status: .valid)
    mockCredential.status = .unknown

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .valid)
    mockCredential.status = .valid
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_expired() async throws {
    anyCredentialSpy.validUntil = Date().advanced(by: -10)
    mockUpdate(expectedStatus: .expired)
    mockCredential.status = .valid

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .expired)
    mockCredential.status = .expired
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(validatorSpy.validateIssuerCalled)
  }

  func testCheckCredentialStatus_validInFutureInsideBuffer() async throws {
    mockCredential.status = .unknown
    anyCredentialSpy.validFrom = Date().advanced(by: Self.buffer - 1)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .valid)
    mockCredential.status = .valid
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_validInFuture() async throws {
    anyCredentialSpy.validFrom = Date().advanced(by: Self.buffer + 1)
    mockUpdate(expectedStatus: .notYetValid)
    mockCredential.status = .valid

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .notYetValid)
    mockCredential.status = .notYetValid
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(validatorSpy.validateIssuerCalled)
  }

  func testCheckCredentialStatus_suspended() async throws {
    success(status: .suspended, validatorStatus: .suspended)
    mockCredential.status = .valid

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .suspended)
    mockCredential.status = .suspended
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_revoked() async throws {
    success(status: .revoked, validatorStatus: .revoked)
    mockCredential.status = .suspended

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .revoked)
    mockCredential.status = .revoked
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_unsupported() async throws {
    success(status: .unsupported, validatorStatus: .unsupported)
    mockCredential.status = .valid

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .unsupported)
    mockCredential.status = .unsupported
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_unknownIsNotSavedInRepository() async throws {
    success(status: .unknown, validatorStatus: .unknown)
    mockCredential.status = .valid

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .valid)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(credentialRepository.updateVerifiableCredentialCalled)
  }

  func testCheckCredentialStatus_noStatus_returnsUnknown() async throws {
    anyCredentialSpy.status = nil
    mockCredential.status = .unknown

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .unknown)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(credentialRepository.updateVerifiableCredentialCalled)
  }

  func testCheckCredentialStatus_noValidator_returnsUnknown() async throws {
    Container.shared.statusValidators.register { [:] }
    useCase = CheckAndUpdateCredentialStatusUseCase()
    mockCredential.status = .unknown

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credential.status, .unknown)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(credentialRepository.updateVerifiableCredentialCalled)
  }

  func testCheckCredentialStatusBatch() async throws {
    mockCredential.status = .unknown
    success(status: .valid)

    let credentials = try await useCase.execute([mockCredential])

    XCTAssertEqual(credentials.first?.status, .valid)
    mockCredential.status = .valid
    XCTAssertEqual(credentials.first, mockCredential)
  }

  // MARK: Private

  // swiftlint:disable all
  private static let issuer = "issuer"
  private static let buffer = 5.0

  private var mockCredential: VerifiableCredential!
  private var anyCredentialSpy: AnyCredentialSpy!

  private var createAnyCredentialSpy: CreateAnyCredentialUseCaseProtocolSpy!
  private var validatorSpy: AnyStatusCheckValidatorProtocolSpy!
  private var credentialRepository: CredentialRepositoryProcotolSpy!

  private var useCase = CheckAndUpdateCredentialStatusUseCase()

  // swiftlint:enable all

  private func success(status: CredentialStatus = .valid, validatorStatus: VcStatus = .valid) {
    mockCredential = VerifiableCredential(progressionState: .accepted, payload: CredentialPayload.Mock.default, format: "vc+sd-jwt", issuer: Self.issuer)
    let anyStatusSpy = AnyStatusSpy()
    anyStatusSpy.type = .tokenStatusList
    anyCredentialSpy.status = anyStatusSpy
    anyCredentialSpy.issuer = Self.issuer
    anyCredentialSpy.validFrom = nil
    anyCredentialSpy.validUntil = nil

    createAnyCredentialSpy.executeFromFormatClosure = { payload, format in
      guard payload == self.mockCredential.payload, format == self.mockCredential.format else { fatalError("Received wrong arguments") }
      return self.anyCredentialSpy
    }
    mockValidator(status: validatorStatus)
    mockUpdate(expectedStatus: status)
  }

  private func mockValidator(status: VcStatus) {
    validatorSpy.validateIssuerClosure = { anyStatus, issuer in
      guard anyStatus.type == self.anyCredentialSpy.status?.type, issuer == Self.issuer else { fatalError("Received wrong arguments") }
      return status
    }
  }

  private func mockUpdate(expectedStatus: CredentialStatus) {
    credentialRepository.updateVerifiableCredentialClosure = { credential in
      var credentialCopy: VerifiableCredential = self.mockCredential
      credentialCopy.status = expectedStatus
      guard credential == credentialCopy else { fatalError("Received wrong arguments") }
      return credential
    }
  }

}
