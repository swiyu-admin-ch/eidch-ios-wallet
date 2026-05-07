import BITActivity
import Factory
import Foundation
import Spyable

// MARK: - GetActivityActorDisplayUseCaseProtocol

@Spyable
protocol GetActivityActorDisplayUseCaseProtocol {
  func callAsFunction(_ activityId: UUID) throws -> ActivityActorDisplay?
}

// MARK: - GetActivityActorDisplayUseCase

struct GetActivityActorDisplayUseCase: GetActivityActorDisplayUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ activityId: UUID) throws -> ActivityActorDisplay? {
    try repository.getActivityActorDisplay(activityId)
  }

  // MARK: Private

  @Injected(\.nonComplianceRepository) private var repository
}
