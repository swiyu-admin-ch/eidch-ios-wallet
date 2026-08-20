import BITAnalytics
import Factory
import Foundation

struct AnalyticsRepository: AnalyticsRepositoryProtocol {

  func allowAnalytics(_ allow: Bool) async {
    UserDefaults.standard.set(allow, forKey: analyticsEnabledKey)

    if allow {
      analytics.register(DynatraceProvider())
    }

    await analytics.applyUserPrivacyPolicy(allow)
  }

  func isAnalyticsAllowed() -> Bool {
    UserDefaults.standard.bool(forKey: analyticsEnabledKey)
  }

  @Injected(\.analytics) private var analytics: AnalyticsProtocol

  private let analyticsEnabledKey = "isAnalyticsUsageAllowed"
}
