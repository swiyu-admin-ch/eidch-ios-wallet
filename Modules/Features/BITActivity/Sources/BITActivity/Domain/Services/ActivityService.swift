import Factory
import Foundation
import Spyable

// MARK: - ActivityServiceProtocol

@Spyable
public protocol ActivityServiceProtocol {
  func create(_ activity: Activity, credentialId: UUID) throws
}

// MARK: - ActivityService

struct ActivityService: ActivityServiceProtocol {
  func create(_ activity: Activity, credentialId: UUID) throws {
    guard try activityRepository.isActivityHistoryEnabled() else { return }
    _ = try activityRepository.create(activity, credentialId: credentialId)
  }

  @Injected(\.activityRepository) private var activityRepository
}
