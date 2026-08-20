import Factory
import FactoryTesting
import Spyable
import Testing
@testable import BITSettings

@Suite(.container)
struct UpdateAnalyticStatusUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let analyticsRepository = AnalyticsRepositoryProtocolSpy()
    Container.shared.analyticsRepository.register { analyticsRepository }

    self.analyticsRepository = analyticsRepository
    useCase = UpdateAnalyticStatusUseCase()
  }

  // MARK: Internal

  @Test
  func executeSuccess() async {
    let mockAllowAnalytics = true
    await useCase(isAllowed: mockAllowAnalytics)

    #expect(analyticsRepository.allowAnalyticsCalled)
    #expect(analyticsRepository.allowAnalyticsReceivedInvocations.first == mockAllowAnalytics)
  }

  // MARK: Private

  private let useCase: UpdateAnalyticStatusUseCaseProtocol
  private let analyticsRepository: AnalyticsRepositoryProtocolSpy
}
