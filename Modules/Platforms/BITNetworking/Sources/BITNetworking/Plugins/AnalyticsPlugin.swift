import BITAnalytics
import Factory
import Foundation
import Moya

// MARK: - AnalyticsPlugin

public struct AnalyticsPlugin: PluginType {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
    if case .failure(let error) = result {
      if let networkError = NetworkError(moyaError: error) {
        if networkError.status == .timeout {
          analytics.log(AnalyticsEvent.networkTimeout)
        } else if networkError.status == .payloadTooLarge {
          analytics.log(AnalyticsEvent.maxResponseSizeExceeded)
        }
      }
    }
    return result
  }

  // MARK: Private

  @Injected(\.analytics) private var analytics
}

// MARK: AnalyticsPlugin.AnalyticsEvent

extension AnalyticsPlugin {
  enum AnalyticsEvent: AnalyticsEventProtocol {
    case networkTimeout
    case maxResponseSizeExceeded
  }
}
