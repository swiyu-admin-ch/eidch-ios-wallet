import BITActivity
import BITAppAttestation
import BITAppAuth
import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - SubmitNonComplianceReportUseCaseError

enum SubmitNonComplianceReportUseCaseError: Error {
  case linkedCredentialError
}

// MARK: - SubmitNonComplianceReportUseCaseProtocol

@Spyable
protocol SubmitNonComplianceReportUseCaseProtocol {
  func execute(
    category: NonComplianceCategory,
    description: String,
    email: String?,
    activity: Activity) async throws
}

// MARK: - SubmitNonComplianceReportUseCase

struct SubmitNonComplianceReportUseCase: SubmitNonComplianceReportUseCaseProtocol {

  // MARK: Internal

  func execute(
    category: NonComplianceCategory,
    description: String,
    email: String?,
    activity: Activity) async throws
  {
    guard let credential = activity.credential else {
      throw SubmitNonComplianceReportUseCaseError.linkedCredentialError
    }
    let report = createReport(category: category, description: description, email: email, activity: activity, credential: credential)

    guard userSession.isLoggedIn, let context = userSession.context else {
      throw UserSessionError.notLoggedIn
    }
    // ensuring existing client attestation
    _ = try await fetchClientAttestationUseCase.execute(context)

    try await nonComplianceRepository.create(report)
  }

  // MARK: Private

  @Injected(\.nonComplianceRepository) private var nonComplianceRepository: NonComplianceRepositoryProtocol
  @Injected(\.fetchClientAttestationUseCase) private var fetchClientAttestationUseCase: FetchClientAttestationUseCaseProtocol
  @Injected(\.userSession) private var userSession: Session

  private func createReport(
    category: NonComplianceCategory,
    description: String,
    email: String?,
    activity: Activity,
    credential: VerifiableCredential)
    -> NonComplianceReport
  {
    switch category {
    case .excessiveDataRequest: NonComplianceExcessiveDataReport(
        description: description,
        email: email,
        activity: activity,
        credential: credential)
    }
  }
}
