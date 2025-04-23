import Factory
import Spyable


@Spyable
public protocol DeleteEIDRequestCaseUseCaseProtocol {
  func execute(_ requestCase: EIDRequestCase) async throws
}


struct DeleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol {
  func execute(_ requestCase: EIDRequestCase) async throws {
    try await repository.delete(requestCase)
  }

  @Injected(\.localEIDRequestRepository) private var repository: LocalEIDRequestRepositoryProtocol
}
