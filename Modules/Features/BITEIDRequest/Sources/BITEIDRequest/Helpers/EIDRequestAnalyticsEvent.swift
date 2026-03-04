import BITAnalytics
import Foundation

enum EIDRequestAnalyticsEvent: AnalyticsEventProtocol {
  case nfcScanRetry(attemptNumber: Int)
  case nfcScanSkipped(afterAttempts: Int)

  // MARK: Internal

  func name(_ provider: AnalyticsProviderProtocol.Type) -> String {
    switch self {
    case .nfcScanRetry: "nfcScanRetry"
    case .nfcScanSkipped: "nfcScanSkipped"
    }
  }

  func parameters(_ provider: AnalyticsProviderProtocol.Type) -> Parameters {
    switch self {
    case .nfcScanRetry(let attemptNumber):
      ["attemptNumber": attemptNumber]
    case .nfcScanSkipped(let afterAttempts):
      ["afterAttempts": afterAttempts]
    }
  }
}
