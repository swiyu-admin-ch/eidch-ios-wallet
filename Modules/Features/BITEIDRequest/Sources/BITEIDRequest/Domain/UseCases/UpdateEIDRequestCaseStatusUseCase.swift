import Factory
import Spyable


@Spyable
public protocol UpdateEIDRequestCaseStatusUseCaseProtocol {
  func execute(_ requestCaseIds: [String]) async throws -> [EIDRequestCase]

  @discardableResult
  func execute(for requestCaseId: String) async throws -> EIDRequestCase
}


struct UpdateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol {

  // MARK: Internal

  func execute(_ requestCaseIds: [String]) async throws -> [EIDRequestCase] {
    try await withThrowingTaskGroup(of: EIDRequestCase.self, returning: [EIDRequestCase].self) { taskGroup in
      for requestCaseId in requestCaseIds {
        taskGroup.addTask {
          try await execute(for: requestCaseId)
        }
      }

      let requestCases = try await taskGroup.reduce(into: [EIDRequestCase]()) { updatedRequestCases, requestCase in
        updatedRequestCases.append(requestCase)
      }

      return requestCases
        .sorted { $0.createdAt > $1.createdAt }
        .reorder(by: requestCasePriorityOrder, using: { $0.state?.state ?? .unknown })
    }
  }

  func execute(for requestCaseId: String) async throws -> EIDRequestCase {
    let requestCase = try await eIDRequestCaseRepository.get(id: requestCaseId)

    do {
      let status = try await eIDRequestRepository.fetchRequestStatus(for: requestCaseId)
      return try await updateRequestCase(requestCase, with: status)
    } catch {
      return requestCase
    }
  }

  // MARK: Private

  @Injected(\.requestCasePriorityOrder) private var requestCasePriorityOrder: [EIDRequestStatus.State]
  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol

  private func updateRequestCase(_ requestCase: EIDRequestCase, with status: EIDRequestStatus) async throws -> EIDRequestCase {
    var requestCaseCopy = requestCase
    requestCaseCopy.state = EIDRequestState(status: status)

    return try await eIDRequestCaseRepository.update(requestCaseCopy)
  }
}
