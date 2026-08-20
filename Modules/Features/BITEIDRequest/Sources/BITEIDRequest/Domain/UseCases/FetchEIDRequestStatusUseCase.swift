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
    try await sidRepository.fetchRequestStatus(for: caseId)
  }

  @Injected(\.sidRepository) private var sidRepository
}
