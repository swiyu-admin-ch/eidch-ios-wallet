import Factory
import Foundation
import Spyable

// MARK: - SetActivityHistoryEnabledUseCaseProtocol

@Spyable
public protocol SetActivityHistoryEnabledUseCaseProtocol {
  func callAsFunction(_ isEnabled: Bool) throws
}

// MARK: - SetActivityHistoryEnabledUseCase

struct SetActivityHistoryEnabledUseCase: SetActivityHistoryEnabledUseCaseProtocol {

  func callAsFunction(_ isEnabled: Bool) throws {
    try activityRepository.setActivityHistoryEnabled(isEnabled)
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
