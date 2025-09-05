import BITAVWrapper
import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
public protocol SaveEIDRequestFilesUseCaseProtocol {
  func execute(_ files: [EIDRequestCaseFile], forRequestCaseId caseId: String) async throws
}


public struct SaveEIDRequestFilesUseCase: SaveEIDRequestFilesUseCaseProtocol {

  @Injected(\.eIDRequestCaseRepository) private var repository

  public func execute(_ files: [EIDRequestCaseFile], forRequestCaseId caseId: String) async throws {
    try await repository.save(files: files, forRequestCaseId: caseId)
  }
}
