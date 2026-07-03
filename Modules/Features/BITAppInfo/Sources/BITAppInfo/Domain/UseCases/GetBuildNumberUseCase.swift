import Factory
import Foundation
import Spyable

// MARK: - GetBuildNumberUseCaseProtocol

@Spyable
public protocol GetBuildNumberUseCaseProtocol {
  func callAsFunction() throws -> BuildNumber
}

// MARK: - GetBuildNumberUseCase

struct GetBuildNumberUseCase: GetBuildNumberUseCaseProtocol {

  func callAsFunction() throws -> BuildNumber {
    try BuildNumber(repository.getBuildNumber())
  }

  @Injected(\.appVersionRepository) private var repository: AppVersionRepositoryProtocol

}
