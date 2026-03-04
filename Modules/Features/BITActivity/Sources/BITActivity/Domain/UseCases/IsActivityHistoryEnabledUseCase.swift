import Factory
import Foundation
import Spyable

// MARK: - IsActivityHistoryEnabledUseCaseProtocol

@Spyable
public protocol IsActivityHistoryEnabledUseCaseProtocol {
  func callAsFunction() throws -> Bool
}

// MARK: - IsActivityHistoryEnabledUseCase

struct IsActivityHistoryEnabledUseCase: IsActivityHistoryEnabledUseCaseProtocol {

  func callAsFunction() throws -> Bool {
    try activityRepository.isActivityHistoryEnabled()
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
