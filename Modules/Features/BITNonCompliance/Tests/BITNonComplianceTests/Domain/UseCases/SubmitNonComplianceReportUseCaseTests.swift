import Factory
import Foundation
import Testing
@testable import BITNonCompliance
@testable import BITTestingCore

struct SubmitNonComplianceReportUseCaseTests {

  // MARK: Lifecycle

  init() {
    let nonComplianceRepository = NonComplianceRepositoryProtocolSpy()
    nonComplianceRepository.getActivityReturnValue = activityMock
    self.nonComplianceRepository = nonComplianceRepository

    Container.shared.nonComplianceRepository.register { nonComplianceRepository }

    useCase = SubmitNonComplianceReportUseCase()
  }

  // MARK: Internal

  @Test
  func execute_success() async throws {
    try await useCase.execute(category: .excessiveDataRequest, description: descriptionMock, email: emailMock, activityId: activityIdMock)

    #expect(nonComplianceRepository.createCallsCount == 1)
    #expect(nonComplianceRepository.getActivityReceivedId == activityIdMock)

    let report = try #require(nonComplianceRepository.createReceivedReport as? NonComplianceExcessiveDataReport)

    #expect(report.description == descriptionMock)
    #expect(report.email == emailMock)
    #expect(report.activity == activityMock)
  }

  @Test
  func execute_repositoryThrowsError_throwsError() async throws {
    nonComplianceRepository.createThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase.execute(category: .excessiveDataRequest, description: descriptionMock, email: emailMock, activityId: activityIdMock)
    }
  }

  // MARK: Private

  private var activityIdMock = UUID()
  private let emailMock = "admin@example.com"
  private var activityMock = NonComplianceActivity.Mock.default
  private let descriptionMock = String(repeating: "x", count: 20)

  private var useCase: SubmitNonComplianceReportUseCase
  private var nonComplianceRepository: NonComplianceRepositoryProtocolSpy
}
