import BITAnalytics
import BITCredentialShared
import BITL10n
import Factory
import Foundation
import Observation

// MARK: - CredentialDetailUpdateViewModel

@MainActor
@Observable
final class CredentialDetailUpdateViewModel {

  // MARK: Lifecycle

  init(credential: CredentialProtocol) {
    mode = .refresh
    self.credential = credential
    issuerDisplay = credential.issuerDisplays.findDisplayWithFallback()
    isLoading = false
    isErrorPresented = false
  }

  init(issuerDisplay: CredentialIssuerDisplay?) {
    mode = .info
    credential = nil
    self.issuerDisplay = issuerDisplay
    isLoading = false
    isErrorPresented = false
  }

  // MARK: Internal

  enum AnalyticsEvent: AnalyticsEventProtocol {
    case refreshCredentialError(_ error: Error)
  }

  enum Mode {
    case refresh
    case info
  }

  enum AccessibilityIdentifier: String {
    case refreshContent = "credentialDetailRefreshContent"
    case refreshCloseButton = "credentialDetailRefreshCloseButton"
    case refreshPrimaryButton = "credentialDetailRefreshPrimaryButton"
    case refreshErrorNotification = "credentialDetailRefreshErrorNotification"
    case infoContent = "credentialDetailUpdateInfoContent"
    case infoCloseButton = "credentialDetailUpdateInfoCloseButton"
  }

  var isLoading: Bool

  var isErrorPresented: Bool

  let issuerDisplay: CredentialIssuerDisplay?

  var title: String {
    switch mode {
    case .refresh:
      L10n.tkDisplayrefreshTitle
    case .info:
      L10n.tkDisplaydeleteWrongdataTitle
    }
  }

  var bodyText: String {
    switch mode {
    case .refresh:
      L10n.tkDisplayrefreshBody
    case .info:
      L10n.tkDisplaydeleteWrongdataBody
    }
  }

  var contentAccessibilityIdentifier: String {
    switch mode {
    case .refresh:
      AccessibilityIdentifier.refreshContent.rawValue
    case .info:
      AccessibilityIdentifier.infoContent.rawValue
    }
  }

  var closeButtonAccessibilityIdentifier: String {
    switch mode {
    case .refresh:
      AccessibilityIdentifier.refreshCloseButton.rawValue
    case .info:
      AccessibilityIdentifier.infoCloseButton.rawValue
    }
  }

  var errorAccessibilityIdentifier: String {
    AccessibilityIdentifier.refreshErrorNotification.rawValue
  }

  var primaryButtonTitle: String? {
    switch mode {
    case .refresh:
      L10n.tkDisplayrefreshButtonPrimarybutton
    case .info:
      nil
    }
  }

  var primaryButtonAccessibilityIdentifier: String {
    AccessibilityIdentifier.refreshPrimaryButton.rawValue
  }

  var errorTitle: String? {
    L10n.tkErrorGenericPrimary
  }

  var errorMessage: String {
    L10n.tkErrorGenericSecondary
  }

  func primaryAction(onSuccess: @escaping (VerifiableCredential) -> Void) async {
    guard
      mode == .refresh,
      !isLoading,
      let refreshableCredential
    else {
      return
    }

    isErrorPresented = false
    isLoading = true
    defer { isLoading = false }

    do {
      let refreshedCredential = try await refreshCredentialUseCase(refreshableCredential)
      onSuccess(refreshedCredential)
    } catch {
      analytics.log(AnalyticsEvent.refreshCredentialError(error))
      isErrorPresented = true
    }
  }

  func hideError() {
    isErrorPresented = false
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.refreshCredentialUseCase) private var refreshCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocol

  private let credential: CredentialProtocol?
  private let mode: Mode

  private var refreshableCredential: VerifiableCredential? {
    guard
      let credential = credential as? VerifiableCredential,
      credential.authentication.refreshToken != nil
    else {
      return nil
    }

    return credential
  }
}
