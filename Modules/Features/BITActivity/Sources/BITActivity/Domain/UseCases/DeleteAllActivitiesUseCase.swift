import Factory
import Foundation
import Spyable

// MARK: - DeleteAllActivitiesUseCaseProtocol

@Spyable
public protocol DeleteAllActivitiesUseCaseProtocol {
  func callAsFunction() throws
}

// MARK: - DeleteAllActivitiesUseCase

struct DeleteAllActivitiesUseCase: DeleteAllActivitiesUseCaseProtocol {

  func callAsFunction() throws {
    try activityRepository.deleteAll()
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
