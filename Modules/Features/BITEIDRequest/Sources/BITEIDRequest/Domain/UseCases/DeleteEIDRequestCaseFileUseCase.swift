import Factory
import Foundation


protocol DeleteEIDRequestCaseFileUseCaseProtocol {
  func execute(forRequestCaseId id: String) async throws
}


struct DeleteEIDRequestCaseFileUseCase: DeleteEIDRequestCaseFileUseCaseProtocol {

  // MARK: Internal

  func execute(forRequestCaseId id: String) async throws {
    try await repository.deleteAllFiles(forRequestCaseId: id)
  }

  // MARK: Private

  @Injected(\.eIDRequestCaseRepository) private var repository: EIDRequestCaseRepositoryProtocol
}
