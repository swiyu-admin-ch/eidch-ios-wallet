import Factory
import Foundation
import Spyable

// MARK: - GetCredentialActivitiesUseCaseProtocol

@Spyable
public protocol GetCredentialActivitiesUseCaseProtocol {
  func callAsFunction(for credentialId: UUID, limit: Int) throws -> [Activity]
}

extension GetCredentialActivitiesUseCaseProtocol {
  public func callAsFunction(for credentialId: UUID) throws -> [Activity] {
    try callAsFunction(for: credentialId, limit: Int.max)
  }
}

// MARK: - GetCredentialActivitiesUseCase

struct GetCredentialActivitiesUseCase: GetCredentialActivitiesUseCaseProtocol {

  func callAsFunction(for credentialId: UUID, limit: Int = Int.max) throws -> [Activity] {
    try activityRepository.getAll(for: credentialId, limit: limit)
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
