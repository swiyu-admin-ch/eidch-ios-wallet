import BITAnalytics
import BITAVWrapper
import BITL10n
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI

// MARK: - NFCScanViewModel

@MainActor
class NFCScanViewModel: ObservableObject {

  // MARK: Lifecycle

  init() {
    avBeam.messageDelegate = self
    avBeam.nfcDelegate = self
  }

  // MARK: Internal

  enum State {
    case sdkInitializing
    case ready
  }

  enum NFCScanViewModelError: Error {
    case nfcScanFailed
  }

  @Published var state = State.sdkInitializing
  @Published var destination: EIDRequestDestinations?

  func initializeSDK() {
    if avBeam.state == .initializing {
      return
    }

    if avBeam.state == .initialized {
      return state = .ready
    }

    let config = AVBeamInitConfig(appId: avBeamAppID)

    do {
      try avBeam.initialize(using: config)
    } catch {
      handleError(error, action: { [weak self] in
        try? self?.avBeam.initialize(using: config)
      })
    }
  }

  func startNFCScan() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      guard let authenticationToken = context.autoVerificationResponse?.jwt else {
        throw EIDRequestError.missingAuthenticationToken
      }

      let config = try await avBeamNFCConfigurator.configure(for: caseId, authenticationToken: authenticationToken)

      NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)
      try avBeam.startNfcScan(config: config)
    } catch {
      NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
      handleError(error, action: { [weak self] in
        Task {
          await self?.startNFCScan()
        }
      })
    }
  }

  // MARK: Private

  private var scanResult: AVBeamPackageResult?
  private var failedNFCScanAttempts = 0
  @Injected(\.maxFailedNFCScanAttempts) private var maxFailedNFCScanAttempts

  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.avBeam) private var avBeam
  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.eidRequestContext) private var context
  @Injected(\.avBeamNFCConfigurator) private var avBeamNFCConfigurator: AVBeamNFCConfiguratorProtocol

  private func getNextDestination() -> EIDRequestDestinations {
    guard let response = context.autoVerificationResponse else {
      return .avIntroSelfieVideo // autoVerificationResponse should always be present at this stage
    }

    if response.isScanDocumentRequired {
      return .scanDocumentInformation(isBackEnabled: false)
    }

    if response.isDocumentVideoRecordingRequired {
      return .recordDocumentInformation
    }

    return .avIntroSelfieVideo
  }

  private func handleError(_ error: Error, action: (() -> Void)? = nil) {
    analytics.log(error)
    destination = .error(.retry(error, { navigator in
      navigator.pop()
      action?() }))
  }

  private func handleScanFailure(_ error: Error) {
    analytics.log(error)
    failedNFCScanAttempts += 1
    destination = .error(nfcFailureDataset(error))
  }

  private func nfcFailureDataset(_ error: Error) -> ErrorDataset {
    if failedNFCScanAttempts >= maxFailedNFCScanAttempts {
      return .nfcScanFailedRetryOrContinue(
        error,
        continueAction: { [weak self] navigator in
          self?.continueAction(navigator)
        },
        retryAction: { [weak self] navigator in
          self?.retryAction(navigator)
        })
    }

    return .nfcScanRetryOnly(error) { [weak self] navigator in
      self?.retryAction(navigator)
    }
  }

  private func retryAction(_ navigator: Navigator) {
    analytics.log(EIDRequestAnalyticsEvent.nfcScanRetry(attemptNumber: failedNFCScanAttempts + 1))
    navigator.pop()
    Task {
      await startNFCScan()
    }
  }

  private func continueAction(_ navigator: Navigator) {
    analytics.log(EIDRequestAnalyticsEvent.nfcScanSkipped(afterAttempts: failedNFCScanAttempts))
    failedNFCScanAttempts = 0
    navigator.navigate(to: getNextDestination())
  }

}

// MARK: AVBeamMessageDelegate

extension NFCScanViewModel: AVBeamMessageDelegate {

  func didReceiveError(error: AVBeamError) {
    Task { @MainActor in
      analytics.log(error)
    }
  }

  func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.state = .ready
      default: break
      }
    }
  }
}

// MARK: AVBeamNfcDelegate

extension NFCScanViewModel: AVBeamNfcDelegate {
  func didCompleteNfcScan(packageResult: AVBeamPackageResult) {
    NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
    guard packageResult.data.nfcError == .none else {
      return handleScanFailure(packageResult.data.nfcError)
    }

    guard packageResult.data.errorCode == .none else {
      return handleScanFailure(packageResult.data.errorCode)
    }

    scanResult = packageResult
    failedNFCScanAttempts = 0

    if let scanResult {
      destination = .nfcScanResult(scanResult)
    }
  }
}

extension ErrorDataset {
  static func nfcScanRetryOnly(_ error: Error, _ retryAction: @escaping (Navigator) -> Void) -> ErrorDataset {
    ErrorDataset(nfcScanErrorContents(error: error), actions: [
      .primary(L10n.tkEidRequestNfcScanErrorButtonRetry, retryAction),
    ])
  }

  static func nfcScanFailedRetryOrContinue(
    _ error: Error,
    continueAction: @escaping (Navigator) -> Void,
    retryAction: @escaping (Navigator) -> Void)
    -> ErrorDataset
  {
    ErrorDataset(nfcScanFailedContents(error: error), actions: [
      .primary(L10n.tkEidRequestNfcScanErrorFailedButtonContinue, continueAction),
      .secondary(L10n.tkEidRequestNfcScanErrorFailedButtonRetry, retryAction),
    ])
  }

  static func nfcScanErrorContents(error: Error) -> [InformationView2.ContentType] {
    [
      .title(L10n.tkEidRequestNfcScanErrorPrimary),
      .body(L10n.tkEidRequestNfcScanErrorSecondary),
      .captionErrorDescription(error),
    ]
  }

  static func nfcScanFailedContents(error: Error) -> [InformationView2.ContentType] {
    [
      .title(L10n.tkEidRequestNfcScanErrorFailedPrimary),
      .body(L10n.tkEidRequestNfcScanErrorFailedSecondary),
      .captionErrorDescription(error),
    ]
  }
}
