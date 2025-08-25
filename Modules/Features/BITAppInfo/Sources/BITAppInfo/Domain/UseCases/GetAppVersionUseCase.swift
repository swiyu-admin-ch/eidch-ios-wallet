import Factory
import Foundation
import Spyable

// MARK: - GetAppVersionUseCaseProtocol

@Spyable
public protocol GetAppVersionUseCaseProtocol {
  func execute() throws -> AppVersion
}

// MARK: - GetAppVersionUseCase

struct GetAppVersionUseCase: GetAppVersionUseCaseProtocol {

  func execute() throws -> AppVersion {
    try AppVersion(repository.getVersion())
  }

  @Injected(\.appVersionRepository) private var repository: AppVersionRepositoryProtocol

}
