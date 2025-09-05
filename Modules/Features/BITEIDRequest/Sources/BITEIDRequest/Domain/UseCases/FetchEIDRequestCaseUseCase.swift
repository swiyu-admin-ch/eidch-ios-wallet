import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
protocol FetchEIDRequestCaseUseCaseProtocol {
  func execute(caseId: String) async throws -> EIDRequestCase
}


struct FetchEIDRequestCaseUseCase: FetchEIDRequestCaseUseCaseProtocol {
  func execute(caseId: String) async throws -> EIDRequestCase {
    try await repository.get(id: caseId)
  }

  @Injected(\.eIDRequestCaseRepository) private var repository
}
