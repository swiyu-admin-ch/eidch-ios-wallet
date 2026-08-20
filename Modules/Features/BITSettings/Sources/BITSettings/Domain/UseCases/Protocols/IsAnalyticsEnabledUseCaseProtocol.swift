import Foundation
import Spyable

@Spyable
public protocol IsAnalyticsEnabledUseCaseProtocol {
  func callAsFunction() -> Bool
}
