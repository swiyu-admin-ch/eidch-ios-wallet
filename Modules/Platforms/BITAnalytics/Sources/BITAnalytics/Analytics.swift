import Foundation

// MARK: - Analytics

public typealias AnalyticsProtocol = Loggable & PrivacySettable & ProviderRegisterable

// MARK: - Analytics

final class Analytics: AnalyticsProtocol {

  private(set) var isAnalyticsEnabled = false
  private(set) var providers = [AnalyticsProviderProtocol]()

  func log(_ event: AnalyticsEventProtocol) {
    guard isAnalyticsEnabled else {
      return
    }

    for provider in providers {
      provider.log(event)
    }
  }

  func log(_ errorEvent: AnalyticsErrorEventProtocol) {
    guard isAnalyticsEnabled else {
      return
    }

    for provider in providers {
      provider.log(errorEvent)
    }
  }

  func log(_ error: Error) {
    guard isAnalyticsEnabled else {
      return
    }

    for provider in providers {
      provider.log(error)
    }
  }

  func register(_ provider: any AnalyticsProviderProtocol) {
    guard !providers.contains(where: { type(of: provider).identifier == type(of: $0).identifier }) else { return }
    providers.append(provider)
  }

  func applyUserPrivacyPolicy(_ isEnabled: Bool) async {
    isAnalyticsEnabled = isEnabled

    for provider in providers {
      await provider.applyUserPrivacyPolicy(isEnabled)
    }
  }

}
