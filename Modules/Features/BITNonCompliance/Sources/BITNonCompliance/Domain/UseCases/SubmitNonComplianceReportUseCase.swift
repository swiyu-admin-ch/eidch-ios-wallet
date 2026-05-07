import BITActivity
import BITAppAttestation
import BITAppAuth
import BITCredentialShared
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

    guard userSession.isLoggedIn, let context = userSession.context else {
      throw UserSessionError.notLoggedIn
    }
    // ensuring existing client attestation
    _ = try await clientAttestationRepository.get(using: context)

    try await nonComplianceRepository.create(report)
  }

  // MARK: Private

  @Injected(\.nonComplianceRepository) private var nonComplianceRepository: NonComplianceRepositoryProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.userSession) private var userSession: Session

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
