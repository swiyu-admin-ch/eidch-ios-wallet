
import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITAnalytics
@testable import BITSettings

@Suite(.container)
struct AnalyticsRepositoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    UserDefaults.standard.removeObject(forKey: analyticsEnabledKey)

    let analytics = AnalyticsSpy()
    Container.shared.analytics.register { analytics }

    self.analytics = analytics
    repository = AnalyticsRepository()
  }

  // MARK: Internal

  @Test
  func allowAnalytics_isTrue_success() async {
    await repository.allowAnalytics(true)

    #expect(repository.isAnalyticsAllowed() == true)

    #expect(analytics.registerCallsCount == 1)
    #expect(analytics.registerReceivedArguments?.provider is DynatraceProvider)

    #expect(analytics.applyUserPrivacyPolicyCallsCount == 1)
    #expect(analytics.applyUserPrivacyPolicyReceivedArguments?.isEnabled == true)
  }

  @Test
  func allowAnalytics_isFalse_success() async {
    await repository.allowAnalytics(false)

    #expect(repository.isAnalyticsAllowed() == false)

    #expect(!analytics.registerCalled)

    #expect(analytics.applyUserPrivacyPolicyCallsCount == 1)
    #expect(analytics.applyUserPrivacyPolicyReceivedArguments?.isEnabled == false)
  }

  @Test(arguments: [true, false])
  func isAnalyticsAllowed_success(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: analyticsEnabledKey)

    #expect(repository.isAnalyticsAllowed() == value)
  }

  // MARK: Private

  private let analytics: AnalyticsSpy
  private let repository: AnalyticsRepository

  private let analyticsEnabledKey = "isAnalyticsUsageAllowed"
}
