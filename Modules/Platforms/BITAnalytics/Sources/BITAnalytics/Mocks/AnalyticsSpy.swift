final class AnalyticsSpy: AnalyticsProtocol {

  struct LogEventReceivedArguments {
    let event: AnalyticsEventProtocol
  }

  struct LogErrorEventReceivedArguments {
    let errorEvent: AnalyticsErrorEventProtocol
  }

  struct LogErrorReceivedArguments {
    let error: Error
  }

  struct RegisterReceivedArguments {
    let provider: AnalyticsProviderProtocol
  }

  struct ApplyUserPrivacyPolicyReceivedArguments {
    let isEnabled: Bool
  }

  private(set) var providers = [AnalyticsProviderProtocol]()
  private(set) var isAnalyticsEnabled = false

  private(set) var logEventCalled = false
  private(set) var logEventCallsCount = 0
  private(set) var logEventReceivedArguments: LogEventReceivedArguments?
  private(set) var logEventReceivedInvocations = [AnalyticsEventProtocol]()

  private(set) var logErrorEventCalled = false
  private(set) var logErrorEventCallsCount = 0
  private(set) var logErrorEventReceivedArguments: LogErrorEventReceivedArguments?
  private(set) var logErrorEventReceivedInvocations = [AnalyticsErrorEventProtocol]()

  private(set) var logErrorCalled = false
  private(set) var logErrorCallsCount = 0
  private(set) var logErrorReceivedArguments: LogErrorReceivedArguments?
  private(set) var logErrorReceivedInvocations = [Error]()

  private(set) var registerCalled = false
  private(set) var registerCallsCount = 0
  private(set) var registerReceivedArguments: RegisterReceivedArguments?
  private(set) var registerReceivedInvocations = [AnalyticsProviderProtocol]()

  private(set) var applyUserPrivacyPolicyCalled = false
  private(set) var applyUserPrivacyPolicyCallsCount = 0
  private(set) var applyUserPrivacyPolicyReceivedArguments: ApplyUserPrivacyPolicyReceivedArguments?
  private(set) var applyUserPrivacyPolicyReceivedInvocations = [Bool]()

  func log(_ event: AnalyticsEventProtocol) {
    logEventCalled = true
    logEventCallsCount += 1
    logEventReceivedArguments = LogEventReceivedArguments(event: event)
    logEventReceivedInvocations.append(event)

    for provider in providers {
      provider.log(event)
    }
  }

  func log(_ errorEvent: AnalyticsErrorEventProtocol) {
    logErrorEventCalled = true
    logErrorEventCallsCount += 1
    logErrorEventReceivedArguments = LogErrorEventReceivedArguments(errorEvent: errorEvent)
    logErrorEventReceivedInvocations.append(errorEvent)

    for provider in providers {
      provider.log(errorEvent)
    }
  }

  func log(_ error: Error) {
    logErrorCalled = true
    logErrorCallsCount += 1
    logErrorReceivedArguments = LogErrorReceivedArguments(error: error)
    logErrorReceivedInvocations.append(error)

    for provider in providers {
      provider.log(error)
    }
  }

  func register(_ provider: any AnalyticsProviderProtocol) {
    registerCalled = true
    registerCallsCount += 1
    registerReceivedArguments = RegisterReceivedArguments(provider: provider)
    registerReceivedInvocations.append(provider)
    providers.append(provider)
  }

  func applyUserPrivacyPolicy(_ isEnabled: Bool) async {
    isAnalyticsEnabled = isEnabled
    applyUserPrivacyPolicyCalled = true
    applyUserPrivacyPolicyCallsCount += 1
    applyUserPrivacyPolicyReceivedArguments = ApplyUserPrivacyPolicyReceivedArguments(isEnabled: isEnabled)
    applyUserPrivacyPolicyReceivedInvocations.append(isEnabled)
  }
}
