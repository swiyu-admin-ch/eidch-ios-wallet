import Foundation

// MARK: - AnalyticsEvent.HelloWorld

extension AnalyticsEvent {
  struct HelloWorld: AnalyticsEventProtocol {
    var parameter1: String

    func parameters(_ provider: AnalyticsProviderProtocol.Type) -> Parameters {
      [:]
    }
  }
}
