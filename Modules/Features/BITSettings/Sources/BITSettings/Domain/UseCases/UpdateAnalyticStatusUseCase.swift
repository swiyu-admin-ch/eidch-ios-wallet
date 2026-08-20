import Factory
import Foundation
import Spyable

// MARK: - UpdateAnalyticStatusUseCaseProtocol

@Spyable
public protocol UpdateAnalyticStatusUseCaseProtocol {
  func callAsFunction(isAllowed: Bool) async
}

// MARK: - UpdateAnalyticStatusUseCase

struct UpdateAnalyticStatusUseCase: UpdateAnalyticStatusUseCaseProtocol {

  func callAsFunction(isAllowed: Bool) async {
    await analyticsRepository.allowAnalytics(isAllowed)
  }

  @Injected(\.analyticsRepository) private var analyticsRepository: AnalyticsRepositoryProtocol
}
