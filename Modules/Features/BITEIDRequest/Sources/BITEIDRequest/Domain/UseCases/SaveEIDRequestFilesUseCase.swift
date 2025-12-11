import BITAVWrapper
import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
protocol SaveEIDRequestFilesUseCaseProtocol {
  func execute(_ files: [EIDRequestCaseFile], forRequestCaseId caseId: String) async throws
}


struct SaveEIDRequestFilesUseCase: SaveEIDRequestFilesUseCaseProtocol {

  // MARK: Public

  func execute(_ files: [EIDRequestCaseFile], forRequestCaseId caseId: String) async throws {
    try await repository.save(files: files, forRequestCaseId: caseId)
  }

  // MARK: Private

  @Injected(\.eIDRequestCaseRepository) private var repository

}
