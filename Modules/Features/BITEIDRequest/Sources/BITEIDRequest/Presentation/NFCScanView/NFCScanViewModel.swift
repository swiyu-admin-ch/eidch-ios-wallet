import BITAVWrapper
import Factory
import Foundation

// MARK: - NFCScanViewModel

class NFCScanViewModel: ObservableObject {

  // MARK: Lifecycle

  init() {
    avBeam.messageDelegate = self
    avBeam.nfcDelegate = self

    if avBeam.state == AVBeamState.initialized {
      state = .ready
    }
  }

  // MARK: Internal

  enum State {
    case sdkInitializing
    case ready
    case error(_ error: Error)
  }

  @Published var state = State.sdkInitializing
  @Published var destination: EIDRequestDestinations?

  func initializeSDK() {
    do {
      let config = AVBeamInitConfig(appId: avBeamAppID)
      try avBeam.initialize(using: config)
    } catch {
      state = .error(error)
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

      try avBeam.startNfcScan(config: config)
    } catch {
      state = .error(error)
    }
  }

  // MARK: Private

  @Injected(\.avBeam) private var avBeam
  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.eidRequestContext) private var context
  @Injected(\.avBeamNFCConfigurator) private var avBeamNFCConfigurator: AVBeamNFCConfiguratorProtocol
}

// MARK: AVBeamMessageDelegate

extension NFCScanViewModel: AVBeamMessageDelegate {

  func didReceiveError(error: AVBeamError) {}

  func didReceiveNotification(notification: AVBeamNotification) {
    Task { @MainActor in
      switch notification {
      case .initialized:
        self.state = .ready
      default: ()
      }
    }
  }
}

// MARK: AVBeamNfcDelegate

extension NFCScanViewModel: AVBeamNfcDelegate {
  func didCompleteNfcScan(packageResult: AVBeamPackageResult) {
    destination = .nfcScanResult(packageResult)
  }
}
