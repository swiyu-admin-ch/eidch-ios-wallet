import BITCore
import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
public protocol GetEIDRequestCaseListUseCaseProtocol {
  func callAsFunction() async throws -> [EIDRequestCase]
}


struct GetEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() async throws -> [EIDRequestCase] {
    try await eIDRequestCaseRepository.getAll()
      .reorder(by: requestCasePriorityOrder, using: { $0.state?.state ?? .unknown }, thenCompare: { $0.createdAt < $1.createdAt })
  }

  // MARK: Private

  @Injected(\.requestCasePriorityOrder) private var requestCasePriorityOrder: [EIDRequestStatus.State]
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}
