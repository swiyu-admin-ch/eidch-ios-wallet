import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - WalletPairingOfferViewModel

@MainActor
class WalletPairingOfferViewModel: ObservableObject {

  // MARK: Lifecycle

  init(_ didPairWalletHandler: @escaping (Void) -> Void) {
    self.didPairWalletHandler = didPairWalletHandler
    walletPairingPollingManager.delegate = self
  }

  // MARK: Internal

  enum QRCodeViewState: Equatable {
    case loading
    case error
    case result(Data)
  }

  @Published var state = QRCodeViewState.loading
  @Published var destination: EIDRequestDestinations?
  @Published var isNavigationCloseTriggered = false

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
    isNavigationCloseTriggered = true
  }

  func retryFetching() async {
    await fetchPairingQRCode()
  }

  // MARK: Private

  private var didPairWalletHandler: (Void) -> Void

  @Injected(\.eidRequestContext) private var context
  @Injected(\.fetchWalletPairingOfferUseCase) private var fetchWalletPairingOfferUseCase

  private var caseId: String? {
    context.caseId
  }

  private func setState(_ state: QRCodeViewState) {
    withAnimation {
      self.state = state
    }
  }
}

// MARK: WalletPairingPollingDelegate

extension WalletPairingOfferViewModel: WalletPairingPollingDelegate {

  func pollingManager(_ manager: any WalletPairingPollingProtocol, didUpdateState state: WalletPairingPollingManager.State) {
    switch state {
    case .state(let pollingState):
      switch pollingState {
      case .accepted:
        didPairWalletHandler(Void())
        close()
      case .rejected:
        walletPairingPollingManager.stopPolling()
        destination = .walletPairingOfferRejected(Callback(handler: { _ in }))
      case .open:
        break
      }

    case .error(let error):
      #warning("TODO: Dedicated story (TBD)")
      close()
    }
  }
}
