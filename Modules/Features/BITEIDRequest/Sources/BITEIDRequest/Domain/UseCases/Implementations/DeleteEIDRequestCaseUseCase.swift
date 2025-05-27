import Factory
import Spyable


@Spyable
public protocol DeleteEIDRequestCaseUseCaseProtocol {
  func execute(_ id: String) async throws
}


struct DeleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol {
  func execute(_ id: String) async throws {
    try await repository.delete(id)
  }

  @Injected(\.localEIDRequestRepository) private var repository: LocalEIDRequestRepositoryProtocol
}
