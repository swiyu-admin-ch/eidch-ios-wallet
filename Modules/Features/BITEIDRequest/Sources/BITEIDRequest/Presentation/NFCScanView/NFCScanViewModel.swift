import BITAVWrapper
import BITNavigation
import BITTheming
import Factory
import Foundation

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

  func close() {}

  // MARK: Private

  private var scanResult: AVBeamPackageResult?

  @Injected(\.avBeam) private var avBeam
  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.eidRequestContext) private var context
  @Injected(\.avBeamNFCConfigurator) private var avBeamNFCConfigurator: AVBeamNFCConfiguratorProtocol

  private func getNextDestination() -> EIDRequestDestinations {
    guard let response = context.autoVerificationResponse else {
      return .avIntroSelfieVideo // autoVerificationResponse should always be present at this stage
    }

    if response.isScanDocumentRequired {
      return .scanDocumentInformation
    }

    if response.isDocumentVideoRecordingRequired {
      return .recordDocumentInformation
    }

    return .avIntroSelfieVideo
  }

  private func handleError(_ error: Error, action: (() -> Void)? = nil) {
    destination = .error(.retry(error, { navigator in
      navigator.pop()
      action?() }))
  }

}

// MARK: AVBeamMessageDelegate

extension NFCScanViewModel: AVBeamMessageDelegate {

  func didReceiveError(error: AVBeamError) {}

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
      return handleError(packageResult.data.nfcError)
    }

    guard packageResult.data.errorCode == .none else {
      return handleError(packageResult.data.errorCode)
    }

    scanResult = packageResult

    if let scanResult {
      destination = .nfcScanResult(scanResult)
    }
  }
}
