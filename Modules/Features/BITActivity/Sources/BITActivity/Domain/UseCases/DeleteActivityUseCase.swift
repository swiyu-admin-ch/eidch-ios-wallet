import Factory
import Foundation
import Spyable

// MARK: - DeleteActivityUseCaseProtocol

@Spyable
public protocol DeleteActivityUseCaseProtocol {
  func callAsFunction(_ activityId: UUID) throws
}

// MARK: - DeleteActivityUseCase

struct DeleteActivityUseCase: DeleteActivityUseCaseProtocol {

  func callAsFunction(_ activityId: UUID) throws {
    try activityRepository.delete(activityId)
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
