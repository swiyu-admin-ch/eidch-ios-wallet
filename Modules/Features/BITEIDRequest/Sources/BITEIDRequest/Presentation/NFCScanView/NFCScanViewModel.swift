import BITAVWrapper
import BITL10n
import Factory
import Foundation

// MARK: - NFCScanViewModel

class NFCScanViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router

    avBeam.messageDelegate = self

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

  func initializeSDK() {
    do {
      let config = AVBeamInitConfig(appId: avBeamAppID)
      try avBeam.initialize(using: config)
    } catch {
      #warning("TODO: Handle error case here when implemented")
    }
  }

  func startNFCScan() { }

  func stopNFCScan() {
//    avBeam.stopScanDocument()
//    avBeam.shutdown()
  }

  func close() {
    router.close()
  }

  func openHelp() {
    #warning("TODO: Define URL")
    guard let url = URL(string: L10n.tkEidRequestNfcScanHelpLink) else {
      return
    }

    router.openExternalLink(url: url)
  }

  // MARK: Private

  @Injected(\.avBeam) private var avBeam
  @Injected(\.avBeamAppID) private var avBeamAppID

  private let router: EIDRequestInternalRoutes
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
