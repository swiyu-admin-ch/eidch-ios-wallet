import Combine
import Factory
import Foundation
import Spyable

// MARK: - GetActivityHistoryEnabledSubjectUseCaseProtocol

@Spyable
public protocol GetActivityHistoryEnabledSubjectUseCaseProtocol {
  func callAsFunction() -> CurrentValueSubject<Bool, Never>
}

// MARK: - GetActivityHistoryEnabledSubjectUseCase

struct GetActivityHistoryEnabledSubjectUseCase: GetActivityHistoryEnabledSubjectUseCaseProtocol {

  func callAsFunction() -> CurrentValueSubject<Bool, Never> {
    activityRepository.activityHistoryEnabledSubject
  }

  // MARK: Private

  @Injected(\.activityRepository) private var activityRepository
}
