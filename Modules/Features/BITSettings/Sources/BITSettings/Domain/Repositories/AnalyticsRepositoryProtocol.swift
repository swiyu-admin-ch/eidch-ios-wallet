import Foundation
import Spyable

@Spyable
public protocol AnalyticsRepositoryProtocol: Sendable {
  func allowAnalytics(_ allow: Bool) async
  func isAnalyticsAllowed() -> Bool
}
