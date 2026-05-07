import Factory
import Foundation
import Spyable

// MARK: - GetActivityDetailUseCaseProtocol

@Spyable
public protocol GetActivityDetailUseCaseProtocol {
  func callAsFunction(_ activityId: UUID) throws -> ActivityDetail
}

// MARK: - GetActivityDetailUseCase

struct GetActivityDetailUseCase: GetActivityDetailUseCaseProtocol {

  func callAsFunction(_ activityId: UUID) throws -> ActivityDetail {
    try activityRepository.getDetail(activityId)
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
