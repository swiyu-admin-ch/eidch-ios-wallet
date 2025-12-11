import BITEIDRequestShared
import Factory
import Spyable


@Spyable
public protocol UpdateEIDRequestCaseStatusUseCaseProtocol {
  func execute(_ requestCaseIds: [String]) async throws

  @discardableResult
  func execute(for requestCaseId: String) async throws -> EIDRequestCase
}


struct UpdateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol {

  // MARK: Internal

  func execute(_ requestCaseIds: [String]) async throws {
    try await withThrowingTaskGroup(of: EIDRequestCase.self, returning: Void.self) { taskGroup in
      for requestCaseId in requestCaseIds {
        taskGroup.addTask {
          try await execute(for: requestCaseId)
        }
      }

      try await taskGroup.waitForAll()
    }
  }

  func execute(for requestCaseId: String) async throws -> EIDRequestCase {
    var requestCase = try await eIDRequestCaseRepository.get(id: requestCaseId)

    let status = try await eIDRequestRepository.fetchRequestStatus(for: requestCaseId)
    requestCase.state = EIDRequestState(status: status)
    return try await eIDRequestCaseRepository.update(requestCase)
  }

  // MARK: Private

  @Injected(\.requestCasePriorityOrder) private var requestCasePriorityOrder: [EIDRequestStatus.State]
  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol

}
