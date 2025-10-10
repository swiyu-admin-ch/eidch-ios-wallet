import BITEIDRequestShared
import BITL10n
import Factory
import Foundation
import Spyable
import SwiftUI

// MARK: - WalletPairingListViewModel

@MainActor
class WalletPairingListViewModel: ObservableObject, DevicePairingDelegate {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
    walletPairingPollingManager.delegate = self
  }

  // MARK: Internal

  enum DeviceType {
    case current, other
  }

  enum CurrentDevicePairingState: Equatable {
    case initial
    case loading
    case paired(String)
  }

  @Published var isToastPresented = false
  @Published var toastMessage: String?
  @Published var currentDevicePairingState = CurrentDevicePairingState.initial
  @Published var targetWallets: EIDRequestStatus.TargetWallet?

  var isPrimaryButtonDisabled: Bool {
    targetWallets?.pairedWallets.isEmpty ?? true
  }

  var isBackButtonHidden: Bool {
    !isPrimaryButtonDisabled
  }

  var pairedDevicesCounter: Int {
    guard requestCase != nil, let targetWallets else {
      return 0
    }

    return isCurrentDevicePaired ? targetWallets.pairedWallets.count - 1 : targetWallets.pairedWallets.count
  }

  var isCurrentDevicePaired: Bool {
    requestCase?.deferredCredential != nil
  }

  var isLimitReached: Bool {
    targetWallets?.limitReached ?? false
  }

  func pairDevice(_ type: DeviceType) async {
    switch type {
    case .current:
      await pairCurrentDevice()
    case .other:
      clearToast()
      router.avDevicePairingQRCode(delegate: self)
    }
  }

  func primaryAction() {
    router.avIdentityCheck()
  }

  func close() {
    router.close()
    walletPairingPollingManager.stopPolling()
  }

  func didPairWallet() {
    guard let caseId = router.context.caseId else { return }
    toastMessage = L10n.tkEidRequestWalletPairingNotificationSuccess
    isToastPresented = true

    Task { @MainActor in
      do {
        self.requestCase = try await fetchEIDRequestCaseUseCase.execute(caseId: caseId)
        let status = try await fetchEIDRequestStatusUseCase.execute(for: caseId)
        handleStatus(status)
      } catch {
        #warning("TODO: Present error screen (Story TBD)")
      }
    }
  }

  func clearToast() {
    withAnimation {
      isToastPresented = false
      toastMessage = nil
    }
  }

  // MARK: Private

  private var requestCase: EIDRequestCase?
  private let router: EIDRequestInternalRoutes

  @Injected(\.pairWalletUseCase) private var pairWalletUseCase
  @Injected(\.walletPairingDateFormatter) private var walletPairingDateFormatter
  @Injected(\.walletPairingPollingManager) private var walletPairingPollingManager
  @Injected(\.fetchEIDRequestStatusUseCase) private var fetchEIDRequestStatusUseCase
  @Injected(\.fetchEIDRequestCaseUseCase) private var fetchEIDRequestCaseUseCase

  private func handleStatus(_ status: EIDRequestStatus) {
    #warning("React here to the different states (EIDCULTURA-319)")
    guard let targetWallets = status.targetWallets, status.state == .inTargetWalletPairing else {
      return
    }

    withAnimation {
      self.targetWallets = targetWallets
    }
  }

  private func reset() {
    withAnimation {
      clearToast()
    }
  }

  private func pairCurrentDevice() async {
    do {
      guard let caseId = router.context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      setState(.loading)

      let pairingId = try await pairWalletUseCase.execute(for: caseId)
      walletPairingPollingManager.startPolling(for: caseId, pairingId: pairingId)
    } catch {
      setState(.initial)
      walletPairingPollingManager.reset()
    }
  }

  private func updateCurrentDevicePairing() {
    walletPairingPollingManager.stopPolling()
    setState(.paired(walletPairingDateFormatter.string(from: Date())))
  }

  private func setState(_ state: CurrentDevicePairingState) {
    withAnimation {
      self.currentDevicePairingState = state
    }
  }

  private func stopCurrentDevicePairing() {
    setState(.initial)
    walletPairingPollingManager.stopPolling()
  }
}

// MARK: - DevicePairingDelegate

@MainActor @Spyable
protocol DevicePairingDelegate: AnyObject {
  func didPairWallet()
}

// MARK: - WalletPairingListViewModel + WalletPairingPollingDelegate

extension WalletPairingListViewModel: WalletPairingPollingDelegate {

  func pollingManager(_ manager: any WalletPairingPollingProtocol, didUpdateState state: WalletPairingPollingManager.State) {
    switch state {
    case .state(let pollingState):
      switch pollingState {
      case .accepted:
        didPairWallet()
        updateCurrentDevicePairing()
      case .rejected:
        #warning("TODO: Dedicated story (https://jira.bit.admin.ch/browse/EIDCULTURA-382)")
        stopCurrentDevicePairing()
      case .open:
        break
      }

    case .error:
      walletPairingPollingManager.stopPolling()
    }
  }
}
