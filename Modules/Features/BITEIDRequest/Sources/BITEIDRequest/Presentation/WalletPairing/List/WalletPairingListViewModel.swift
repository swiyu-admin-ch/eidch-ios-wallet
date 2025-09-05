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

  @Published var isPrimaryButtonDisabled = true
  @Published var isToastPresented = false
  @Published var toastMessage: String?
  @Published var currentDevicePairingState = CurrentDevicePairingState.initial

  @Published var pairedDevicesCounter = 0
  @Published var isLimitReached = false

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
  }

  func didPairWallet() {
    guard let caseId = router.context.caseId else { return }
    toastMessage = L10n.tkEidRequestWalletPairingNotificationSuccess
    isToastPresented = true

    Task { @MainActor in
      do {
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

  private let router: EIDRequestInternalRoutes

  @Injected(\.fetchEIDRequestStatusUseCase) private var fetchEIDRequestStatusUseCase
  @Injected(\.pairWalletUseCase) private var pairWalletUseCase
  @Injected(\.walletPairingDateFormatter) private var walletPairingDateFormatter

  private func handleStatus(_ status: EIDRequestStatus) {
    #warning("React here to the different states (EIDCULTURA-319)")
    guard let targetWallets = status.targetWallets, status.state == .inTargetWalletPairing else { return }

    withAnimation {
      self.pairedDevicesCounter = targetWallets.pairedWallets.count
      self.isLimitReached = targetWallets.limitReached
      self.isPrimaryButtonDisabled = targetWallets.pairedWallets.count == 0
    }
  }

  private func reset() {
    withAnimation {
      pairedDevicesCounter = 0
      isLimitReached = false
      clearToast()
    }
  }

  private func pairCurrentDevice() async {
    do {
      guard let caseId = router.context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      setState(.loading)

      try await pairWalletUseCase.execute(for: caseId)

      isPrimaryButtonDisabled = false
      setState(.paired(walletPairingDateFormatter.string(from: Date())))
    } catch {
      setState(.initial)
    }
  }

  private func setState(_ state: CurrentDevicePairingState) {
    withAnimation {
      self.currentDevicePairingState = state
    }
  }

}

// MARK: - DevicePairingDelegate

@MainActor @Spyable
protocol DevicePairingDelegate: AnyObject {
  func didPairWallet()
}
