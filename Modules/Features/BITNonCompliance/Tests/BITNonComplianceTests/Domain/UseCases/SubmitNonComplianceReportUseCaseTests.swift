// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITCredentialShared
@testable import BITLocalAuthentication
@testable import BITNonCompliance
@testable import BITTestingCore

@MainActor
final class SubmitNonComplianceReportUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    useCase = SubmitNonComplianceReportUseCase()
    createSuccessState()
  }

  func testExecute_success() async throws {
    try await useCase.execute(category: .excessiveDataRequest, description: descriptionMock, email: emailMock, activityId: activityIdMock)

    XCTAssertEqual(nonComplianceRepositorySpy.createCallsCount, 1)
    XCTAssertEqual(nonComplianceRepositorySpy.getActivityReceivedId, activityIdMock)
    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 1)

    let report = nonComplianceRepositorySpy.createReceivedReport as? NonComplianceExcessiveDataReport
    XCTAssertEqual(report?.description, descriptionMock)
    XCTAssertEqual(report?.email, emailMock)
    XCTAssertEqual(report?.activity, activityMock)
  }

  func testExecute_userSessionNotLoggedIn_throwsError() async throws {
    userSessionSpy.isLoggedIn = false

    do {
      try await useCase.execute(category: .excessiveDataRequest, description: descriptionMock, email: emailMock, activityId: activityIdMock)
      XCTFail("Expected Error")
    } catch {
      XCTAssertEqual(error as? UserSessionError, .notLoggedIn)
    }
  }

  func testExecute_userSessionContextNil_throwsError() async throws {
    userSessionSpy.context = nil

    do {
      try await useCase.execute(category: .excessiveDataRequest, description: descriptionMock, email: emailMock, activityId: activityIdMock)
      XCTFail("Expected Error")
    } catch {
      XCTAssertEqual(error as? UserSessionError, .notLoggedIn)
    }
  }

  func testExecute_clientAttestationThrows_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    do {
      try await useCase.execute(category: .excessiveDataRequest, description: descriptionMock, email: emailMock, activityId: activityIdMock)
      XCTFail("Expected Error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_repositoryThrowsError_throwsError() async throws {
    nonComplianceRepositorySpy.createThrowableError = TestingError.error

    do {
      try await useCase.execute(category: .excessiveDataRequest, description: descriptionMock, email: emailMock, activityId: activityIdMock)
      XCTFail("Expected Error")
    } catch TestingError.error {
      XCTAssertEqual(nonComplianceRepositorySpy.createCallsCount, 1)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  // MARK: Private

  private var useCase: SubmitNonComplianceReportUseCase!

  private var nonComplianceRepositorySpy: NonComplianceRepositoryProtocolSpy!
  private var clientAttestationRepository: ClientAttestationRepositoryProtocolSpy!

  private var activityIdMock = UUID()
  private var activityMock = NonComplianceActivity.Mock.default
  private let clientAttestationMock = ClientAttestationJWT.Mock.sample
  private let descriptionMock = String(repeating: "x", count: 20)
  private let emailMock = "admin@example.com"
  private var userSessionSpy: SessionSpy!

  private func registerMocks() {
    nonComplianceRepositorySpy = NonComplianceRepositoryProtocolSpy()
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    userSessionSpy = SessionSpy()

    Container.shared.nonComplianceRepository.register { @MainActor in self.nonComplianceRepositorySpy }
    Container.shared.clientAttestationRepository.register { @MainActor in self.clientAttestationRepository }
    Container.shared.userSession.register { @MainActor in self.userSessionSpy }
  }

  private func createSuccessState() {
    nonComplianceRepositorySpy.getActivityReturnValue = activityMock
    clientAttestationRepository.getUsingReturnValue = clientAttestationMock
    userSessionSpy.isLoggedIn = true
    userSessionSpy.context = LAContextProtocolSpy()
  }
}
