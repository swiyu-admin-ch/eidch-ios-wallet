// swiftlint:disable force_try
import BITCore
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITSdJWT
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
    Container.shared.selectCredentialBundleItemUseCase.register { self.selectCredentialBundleItemUseCase }

    useCase = CheckAndUpdateCredentialStatusUseCase()

    selectCredentialBundleItemUseCase.callAsFunctionClosure = {
      guard let first = $0.bundleItems.first else { throw CredentialError.noBundleItem }
      return first
    }

    success()
  }

  func testCheckCredentialStatus_valid() async throws {
    success(status: .valid)
    setStatus(.unknown, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .valid)
    setStatus(.valid, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_expired() async throws {
    anyCredentialSpy.validUntil = Date().advanced(by: -10)
    mockUpdate(expectedStatus: .expired)
    setStatus(.valid, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .expired)
    setStatus(.expired, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(validatorSpy.validateIssuerCalled)
  }

  func testCheckCredentialStatus_expiredHasPriorityOverRevoked() async throws {
    success(status: .expired, validatorStatus: .revoked)
    anyCredentialSpy.validUntil = Date().advanced(by: -10)
    setStatus(.valid, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .expired)
    setStatus(.expired, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(validatorSpy.validateIssuerCalled)
  }

  func testCheckCredentialStatus_validInFutureInsideBuffer() async throws {
    setStatus(.unknown, on: &mockCredential)
    anyCredentialSpy.validFrom = Date().advanced(by: Self.buffer - 1)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .valid)
    setStatus(.valid, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_validInFuture() async throws {
    anyCredentialSpy.validFrom = Date().advanced(by: Self.buffer + 1)
    mockUpdate(expectedStatus: .notYetValid)
    setStatus(.valid, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .notYetValid)
    setStatus(.notYetValid, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertTrue(validatorSpy.validateIssuerCalled)
  }

  func testCheckCredentialStatus_notYetValidAndRevoked_returnsRevoked() async throws {
    success(status: .revoked, validatorStatus: .revoked)
    anyCredentialSpy.validFrom = Date().advanced(by: Self.buffer + 1)
    setStatus(.valid, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .revoked)
    setStatus(.revoked, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertTrue(validatorSpy.validateIssuerCalled)
  }

  func testCheckCredentialStatus_suspended() async throws {
    success(status: .suspended, validatorStatus: .suspended)
    setStatus(.valid, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .suspended)
    setStatus(.suspended, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_revoked() async throws {
    success(status: .revoked, validatorStatus: .revoked)
    setStatus(.suspended, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .revoked)
    setStatus(.revoked, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_unsupported() async throws {
    success(status: .unsupported, validatorStatus: .unsupported)
    setStatus(.valid, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .unsupported)
    setStatus(.unsupported, on: &mockCredential)
    XCTAssertEqual(credential, mockCredential)
  }

  func testCheckCredentialStatus_unknownIsNotSavedInRepository() async throws {
    success(status: .unknown, validatorStatus: .unknown)
    setStatus(.valid, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .valid)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(credentialRepository.updateVerifiableCredentialCalled)
  }

  func testCheckCredentialStatus_noStatus_returnsUnknown() async throws {
    anyCredentialSpy.status = nil
    setStatus(.unknown, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .unknown)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(credentialRepository.updateVerifiableCredentialCalled)
  }

  func testCheckCredentialStatus_noValidator_returnsUnknown() async throws {
    Container.shared.statusValidators.register { [:] }
    useCase = CheckAndUpdateCredentialStatusUseCase()
    setStatus(.unknown, on: &mockCredential)

    let credential = try await useCase.execute(for: mockCredential)

    XCTAssertEqual(status(of: credential), .unknown)
    XCTAssertEqual(credential, mockCredential)
    XCTAssertFalse(credentialRepository.updateVerifiableCredentialCalled)
  }

  func testCheckCredentialStatusBatch() async throws {
    setStatus(.unknown, on: &mockCredential)
    success(status: .valid)

    let credentials = try await useCase.execute([mockCredential])

    XCTAssertEqual(credentials.first.map { status(of: $0) }, .valid)
    setStatus(.valid, on: &mockCredential)
    XCTAssertEqual(credentials.first, mockCredential)
  }

  // MARK: Private

  // swiftlint:disable all
  private static let issuer = "issuer"
  private static let buffer = 5.0

  private let issuerUrlMock = "https://issuer"

  private var mockCredential = VerifiableCredential.Mock.sample
  private var anyCredentialSpy: AnyCredentialSpy!

  private var createAnyCredentialSpy: CreateAnyCredentialUseCaseProtocolSpy!
  private var validatorSpy: AnyStatusCheckValidatorProtocolSpy!
  private var credentialRepository: CredentialRepositoryProcotolSpy!
  private let selectCredentialBundleItemUseCase = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var useCase = CheckAndUpdateCredentialStatusUseCase()

  // swiftlint:enable all

  private func success(status: CredentialStatus = .valid, validatorStatus: VcStatus = .valid) {
    let bundleItem = BundleItem(payload: CredentialPayload.Mock.default)
    mockCredential = VerifiableCredential(
      progressionState: .accepted,
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id,
      format: "vc+sd-jwt",
      issuerUrl: issuerUrlMock,
      issuer: Self.issuer,
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let anyStatusSpy = AnyStatusSpy()
    anyStatusSpy.type = .tokenStatusList
    anyCredentialSpy.status = anyStatusSpy
    anyCredentialSpy.issuer = Self.issuer
    anyCredentialSpy.validFrom = nil
    anyCredentialSpy.validUntil = nil

    createAnyCredentialSpy.executeFromFormatClosure = { payload, format in
      guard payload == self.payload(of: self.mockCredential), format == self.mockCredential.format else { fatalError("Received wrong arguments") }
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
      self.setStatus(expectedStatus, on: &credentialCopy)
      guard credential == credentialCopy else { fatalError("Received wrong arguments") }
      return credential
    }
  }

  private func status(of credential: VerifiableCredential) -> CredentialStatus? {
    (try! selectCredentialBundleItemUseCase(credential)).status
  }

  private func payload(of credential: VerifiableCredential) -> CredentialPayload? {
    (try! selectCredentialBundleItemUseCase(credential)).payload
  }

  private func setStatus(_ status: CredentialStatus, on credential: inout VerifiableCredential) {
    let index = try! XCTUnwrap(credential.bundleItems.firstIndex(where: { $0.id == credential.nextPresentableBundleItemId }))
    credential.bundleItems[index].status = status
  }

}
