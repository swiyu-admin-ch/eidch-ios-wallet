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
@Observable
final class NFCScanViewModel {

  // MARK: Lifecycle

  init() {
    avBeam.messageDelegate = self
    avBeam.nfcDelegate = self
  }

  // MARK: Internal

  enum State {
    case loading
    case ready
  }

  enum NFCScanViewModelError: Error {
    case nfcScanFailed
  }

  var state = State.loading
  var destination: EIDRequestDestinations?

  func checkInitializationState() {
    switch avBeam.state {
    case .notInitialized:
      avBeam.shutdown()
      do {
        let config = AVBeamInitConfig(appId: avBeamAppID)
        try avBeam.initialize(using: config)
      } catch {
        handleError(error)
      }

    case .initializing:
      state = .loading

    case .initialized: break
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
  @ObservationIgnored @Injected(\.maxFailedNFCScanAttempts) private var maxFailedNFCScanAttempts

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.avBeam) private var avBeam
  @ObservationIgnored @Injected(\.avBeamAppID) private var avBeamAppID
  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.avBeamNFCConfigurator) private var avBeamNFCConfigurator:
    AVBeamNFCConfiguratorProtocol
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator

  private func continueAction(_ navigator: Navigator) {
    navigator.navigate(to: getNextDestination())
  }

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
      if packageResult.data.nfcError == .nfcSessionInvalidated { return } // nfc timeout - do nothing.
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

// MARK: - Error Handling

extension NFCScanViewModel {

  private func handleError(_ error: Error, action: (() -> Void)? = nil) {
    destination = .error(errorDataset(for: error, action: action))
  }

  private func handleScanFailure(_ error: Error) {
    analytics.log(error)
    failedNFCScanAttempts += 1

    destination = .error(scanFailureDataset(for: error))
  }

  private func nfcFailureDataset(_ error: Error) -> ErrorDataset {
    guard failedNFCScanAttempts >= maxFailedNFCScanAttempts else {
      return .NFC.retry(error) { [weak self] navigator in
        self?.retryNFCScan(navigator)
      }
    }

    return .NFC.retryOrContinue(
      error,
      continueAction: { [weak self] navigator in
        self?.continueAction(navigator)
      },
      retryAction: { [weak self] navigator in
        self?.retryNFCScan(navigator)
      })

  }

  private func scanFailureDataset(for error: Error) -> ErrorDataset {
    guard let avBeamError = error as? AVBeamError else {
      return nfcFailureDataset(error)
    }

    switch avBeamError.errorType {
    case .critical:
      return .NFC.critical(avBeamError, closeAction: closeHandler())
    case .error,
         .warning:
      return nfcFailureDataset(avBeamError)
    }
  }

  private func retryNFCScan(_ navigator: Navigator) {
    analytics.log(EIDRequestAnalyticsEvent.nfcScanRetry(attemptNumber: failedNFCScanAttempts + 1))
    navigator.pop()
    Task {
      await startNFCScan()
    }
  }

  private func retryHandler(_ action: (() -> Void)? = nil) -> (Navigator) -> Void {
    { navigator in
      navigator.pop()
      action?()
    }
  }

  private func errorDataset(for error: Error, action: (() -> Void)? = nil) -> ErrorDataset {
    guard let avBeamError = error as? AVBeamError else {
      return ErrorDataset.retry(error, retryHandler(action))
    }

    return .avBeamError(
      avBeamError, retryAction: retryHandler(action), closeAction: closeHandler())
  }

  private func closeHandler() -> () -> Void {
    { [weak self] in
      self?.coordinator.cleanup()
    }
  }
}
