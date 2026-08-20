import Factory
import Spyable


@Spyable
public protocol DeleteEIDRequestCaseUseCaseProtocol {
  func execute(_ id: String) async throws
}


struct DeleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol {

  // MARK: Internal

  func execute(_ id: String) async throws {
    try await eIDRequestCaseRepository.delete(id)
  }

  // MARK: Private

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}
