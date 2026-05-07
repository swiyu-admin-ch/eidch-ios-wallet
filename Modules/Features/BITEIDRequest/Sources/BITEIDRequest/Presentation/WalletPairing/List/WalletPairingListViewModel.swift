import BITEIDRequestShared
import BITL10n
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import Spyable
import SwiftUI

// MARK: - WalletPairingListViewModel

@MainActor
@Observable
class WalletPairingListViewModel {

  // MARK: Lifecycle

  init(caseId: String) {
    context.caseId = caseId
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

  var toast: Toast?
  var isInitialLoading = true
  var currentDevicePairingState = CurrentDevicePairingState.initial
  var targetWallets: EIDRequestStatus.TargetWallet?

  var destination: EIDRequestDestinations?
  var isNavigationCloseTriggered = false

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

  var currentDevicePairingDate: String? {
    guard let createdAt = requestCase?.deferredCredential?.createdAt else {
      return nil
    }

    return walletPairingDateFormatter.string(from: createdAt)
  }

  var isLimitReached: Bool {
    targetWallets?.limitReached ?? false
  }

  var shouldShowCurrentDeviceSection: Bool {
    switch currentDevicePairingState {
    case .initial:
      isCurrentDevicePaired || !isLimitReached
    case .loading,
         .paired:
      true
    }
  }

  func pairDevice(_ type: DeviceType) async {
    switch type {
    case .current:
      await pairCurrentDevice()
    case .other:
      clearToast()
      destination = .walletPairingOffer(Callback<Void>(handler: didPairWallet))
    }
  }

  func primaryAction() {
    guard let caseId = context.caseId else {
      return
    }

    destination = .avIdentityCheck(caseId: caseId)
  }

  func close() {
    walletPairingPollingManager.stopPolling()
    isNavigationCloseTriggered = true
    coordinator.cleanup()
  }

  func didPairWallet() {
    toast = Toast(L10n.tkEidRequestWalletPairingNotificationSuccess)

    Task { await fetchStatus() }
  }

  func fetchStatus() async {
    guard let caseId = context.caseId else {
      isInitialLoading = false
      return
    }

    defer {
      isInitialLoading = false
    }

    do {
      requestCase = try await fetchEIDRequestCaseUseCase.execute(caseId: caseId)
      let status = try await fetchEIDRequestStatusUseCase.execute(for: caseId)
      handleStatus(status)
    } catch {
      destination = .error(ErrorDataset(error, [
        .primary(L10n.tkGlobalClose, { _ in
          self.close()
        }),
      ]))
    }
  }

  func clearToast() {
    withAnimation {
      toast = nil
    }
  }

  // MARK: Private

  private var requestCase: EIDRequestCase?

  @ObservationIgnored @Injected(\.pairWalletUseCase) private var pairWalletUseCase
  @ObservationIgnored @Injected(\.walletPairingDateFormatter) private var walletPairingDateFormatter
  @ObservationIgnored @Injected(\.walletPairingPollingManager) private var walletPairingPollingManager
  @ObservationIgnored @Injected(\.fetchEIDRequestStatusUseCase) private var fetchEIDRequestStatusUseCase
  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.fetchEIDRequestCaseUseCase) private var fetchEIDRequestCaseUseCase
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator

  private func handleStatus(_ status: EIDRequestStatus) {
    switch status.state {
    case .inTargetWalletPairing:
      guard let targetWallets = status.targetWallets else { return }

      withAnimation {
        self.targetWallets = targetWallets
      }

    default:
      destination = .timeout
    }
  }

  private func reset() {
    withAnimation {
      clearToast()
    }
  }

  private func pairCurrentDevice() async {
    do {
      guard let caseId = context.caseId else {
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

// MARK: WalletPairingPollingDelegate

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
