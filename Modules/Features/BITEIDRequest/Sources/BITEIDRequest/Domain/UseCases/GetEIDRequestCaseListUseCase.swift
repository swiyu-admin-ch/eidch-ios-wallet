import BITCore
import Factory
import Foundation
import Spyable


@Spyable
public protocol GetEIDRequestCaseListUseCaseProtocol {
  func execute() async throws -> [EIDRequestCase]
}


struct GetEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocol {

  // MARK: Internal

  func execute() async throws -> [EIDRequestCase] {
    try await eIDRequestCaseRepository.getAll()
      .filter { $0.state?.state != .cancelled }
      .reorder(by: requestCasePriorityOrder, using: { $0.state?.state ?? .unknown })
  }

  // MARK: Private

  @Injected(\.requestCasePriorityOrder) private var requestCasePriorityOrder: [EIDRequestStatus.State]
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}
