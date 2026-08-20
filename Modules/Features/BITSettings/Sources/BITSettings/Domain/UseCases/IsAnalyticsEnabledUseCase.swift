import Factory
import Foundation

struct IsAnalyticsEnabledUseCase: IsAnalyticsEnabledUseCaseProtocol {

  func callAsFunction() -> Bool {
    analyticsRepository.isAnalyticsAllowed()
  }

  @Injected(\.analyticsRepository) private var analyticsRepository: AnalyticsRepositoryProtocol

}
