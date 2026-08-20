import Dynatrace
import Foundation

// MARK: - DynatraceProvider

public final class DynatraceProvider: AnalyticsProviderProtocol {

  // MARK: Lifecycle

  required public init() {
    Dynatrace.startupWithInfoPlistSettings()
  }

  // MARK: Public

  public func log(_ event: AnalyticsEventProtocol) {
    let provider = Self.self
    let name = event.name(provider)
    let parameters = event.parameters(provider)

    let action = DTXAction.enter(withName: name)
    action?.setParameters(parameters)
    action?.leave()
  }

  public func log(_ errorEvent: AnalyticsErrorEventProtocol) {
    let provider = Self.self
    let name = errorEvent.name(provider)
    let parameters = errorEvent.parameters(provider)
    let error = errorEvent.error()

    let action = DTXAction.enter(withName: name)
    action?.setParameters(parameters)
    action?.reportError(withName: name, error: error)
    action?.leave()
  }

  public func log(_ error: Error) {
    let description = String(describing: error.self)
    DTXAction.reportError(withName: description, error: error)
  }

  public func applyUserPrivacyPolicy(_ isEnabled: Bool) async {
    let privacyConfig = Dynatrace.userPrivacyOptions()
    privacyConfig.dataCollectionLevel = isEnabled ? .performance : .off
    privacyConfig.crashReportingOptedIn = isEnabled
    privacyConfig.crashReplayOptedIn = false

    await Dynatrace.applyUserPrivacyOptions(privacyConfig)
  }
}

extension DTXAction {

  func setParameters(_ parameters: AnalyticsEventProtocol.Parameters) {
    guard let parameters else { return }
    for (_, element) in parameters.enumerated() {
      if let value = element.value as? Int64 {
        reportValue(withName: element.key, intValue: value)
      } else if let value = element.value as? Double {
        reportValue(withName: element.key, doubleValue: value)
      } else {
        reportValue(withName: element.key, stringValue: "\(element.value)")
      }
    }
  }

}
