import Factory
import Foundation
import Spyable

// MARK: - GetAppVersionUseCaseProtocol

@Spyable
public protocol GetAppVersionUseCaseProtocol {
  func callAsFunction() throws -> Version
}

// MARK: - GetAppVersionUseCase

struct GetAppVersionUseCase: GetAppVersionUseCaseProtocol {

  func callAsFunction() throws -> Version {
    try Version(repository.getVersion())
  }

  @Injected(\.appVersionRepository) private var repository: AppVersionRepositoryProtocol

}
