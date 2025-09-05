import Factory
import Foundation
import SwiftUI

// MARK: - AVDevicePairingQRCodeViewModel

@MainActor
class AVDevicePairingQRCodeViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, delegate: DevicePairingDelegate? = nil)
  {
    self.router = router
    self.delegate = delegate

    walletPairingPollingManager.delegate = self
  }

  // MARK: Internal

  enum QRCodeViewState: Equatable {
    case loading
    case error
    case result(Data)
  }

  @Published var state = QRCodeViewState.loading

  @Injected(\.walletPairingPollingManager) var walletPairingPollingManager

  func fetchPairingQRCode() async {
    guard let caseId else {
      setState(.error)
      walletPairingPollingManager.reset()
      return
    }

    setState(.loading)
    walletPairingPollingManager.reset()

    do {
      let pairingOffer = try await fetchWalletPairingOfferUseCase.execute(for: caseId)
      setState(.result(pairingOffer.qrCodeImageData))
      walletPairingPollingManager.startPolling(for: caseId, pairingId: pairingOffer.pairingId)
    } catch {
      setState(.error)
      walletPairingPollingManager.reset()
    }
  }

  func close() {
    walletPairingPollingManager.stopPolling()
    router.close()
  }

  func retryFetching() async {
    await fetchPairingQRCode()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
  private weak var delegate: DevicePairingDelegate?
  @Injected(\.fetchWalletPairingOfferUseCase) private var fetchWalletPairingOfferUseCase

  private var caseId: String? { router.context.caseId }

  private func setState(_ state: QRCodeViewState) {
    withAnimation {
      self.state = state
    }
  }
}

// MARK: WalletPairingPollingDelegate

extension AVDevicePairingQRCodeViewModel: WalletPairingPollingDelegate {

  func pollingManager(_ manager: any WalletPairingPollingProtocol, didUpdateState state: WalletPairingPollingManager.State)
  {
    switch state {
    case .state(let pollingState):
      switch pollingState {
      case .accepted:
        delegate?.didPairWallet()
        close()
      case .rejected:
        #warning("TODO: Dedicated story (https://jira.bit.admin.ch/browse/EIDCULTURA-382)")
        close()
      case .open:
        break
      }

    case .error(let error):
      #warning("TODO: Dedicated story (TBD)")
      close()
    }
  }
}
