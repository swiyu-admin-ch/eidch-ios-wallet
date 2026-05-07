import Factory
import Foundation
import Spyable

// MARK: - GetCredentialActivitiesUseCaseProtocol

@Spyable
public protocol GetCredentialActivitiesUseCaseProtocol {
  func callAsFunction(for credentialId: UUID, limit: Int) throws -> [ActivityListItem]
}

extension GetCredentialActivitiesUseCaseProtocol {
  public func callAsFunction(for credentialId: UUID) throws -> [ActivityListItem] {
    try callAsFunction(for: credentialId, limit: Int.max)
  }
}

// MARK: - GetCredentialActivitiesUseCase

struct GetCredentialActivitiesUseCase: GetCredentialActivitiesUseCaseProtocol {

  func callAsFunction(for credentialId: UUID, limit: Int = Int.max) throws -> [ActivityListItem] {
    if try activityRepository.isActivityHistoryEnabled() {
      return try activityRepository.getAll(for: credentialId, limit: limit)
    }
    return []
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
