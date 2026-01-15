import Factory
import Foundation
import Spyable

// MARK: - GetActivityUseCaseProtocol

@Spyable
public protocol GetActivityUseCaseProtocol {
  func callAsFunction(_ activityId: UUID) throws -> Activity
}

// MARK: - GetActivityUseCase

struct GetActivityUseCase: GetActivityUseCaseProtocol {

  func callAsFunction(_ activityId: UUID) throws -> Activity {
    try activityRepository.get(activityId)
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
