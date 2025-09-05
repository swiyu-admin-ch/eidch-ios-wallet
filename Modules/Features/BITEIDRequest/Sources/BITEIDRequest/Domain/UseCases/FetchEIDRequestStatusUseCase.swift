import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
protocol FetchEIDRequestStatusUseCaseProtocol {
  func execute(for caseId: String) async throws -> EIDRequestStatus
}


struct FetchEIDRequestStatusUseCase: FetchEIDRequestStatusUseCaseProtocol {
  func execute(for caseId: String) async throws -> EIDRequestStatus {
    try await eIDRequestRepository.fetchRequestStatus(for: caseId)
  }

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository
}
