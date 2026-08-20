import Factory
import FactoryTesting
import Spyable
import Testing
@testable import BITSettings

@Suite(.container)
struct IsAnalyticsEnabledUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let analyticsRepository = AnalyticsRepositoryProtocolSpy()
    Container.shared.analyticsRepository.register { analyticsRepository }

    self.analyticsRepository = analyticsRepository
    useCase = IsAnalyticsEnabledUseCase()
  }

  // MARK: Internal

  @Test
  func executeSuccess() {
    analyticsRepository.isAnalyticsAllowedReturnValue = true

    let status = useCase()

    #expect(analyticsRepository.isAnalyticsAllowedCalled)
    #expect(status)
  }

  // MARK: Private

  private let useCase: IsAnalyticsEnabledUseCase
  private let analyticsRepository: AnalyticsRepositoryProtocolSpy
}
