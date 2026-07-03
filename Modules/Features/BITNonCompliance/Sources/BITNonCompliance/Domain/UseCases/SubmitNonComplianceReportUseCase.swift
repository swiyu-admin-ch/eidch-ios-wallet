import Factory
import Foundation
import Spyable

// MARK: - SubmitNonComplianceReportUseCaseProtocol

@Spyable
protocol SubmitNonComplianceReportUseCaseProtocol {
  func execute(
    category: NonComplianceCategory,
    description: String,
    email: String?,
    activityId: UUID) async throws
}

// MARK: - SubmitNonComplianceReportUseCase

struct SubmitNonComplianceReportUseCase: SubmitNonComplianceReportUseCaseProtocol {

  // MARK: Internal

  func execute(
    category: NonComplianceCategory,
    description: String,
    email: String?,
    activityId: UUID) async throws
  {
    let activity = try nonComplianceRepository.getActivity(activityId)
    let report = createReport(category: category, description: description, email: email, activity: activity)

    try await nonComplianceRepository.create(report)
  }

  // MARK: Private

  @Injected(\.nonComplianceRepository) private var nonComplianceRepository: NonComplianceRepositoryProtocol

  private func createReport(
    category: NonComplianceCategory,
    description: String,
    email: String?,
    activity: NonComplianceActivity)
    -> NonComplianceReport
  {
    switch category {
    case .excessiveDataRequest: NonComplianceExcessiveDataReport(
        description: description,
        email: email,
        activity: activity)
    }
  }
}
