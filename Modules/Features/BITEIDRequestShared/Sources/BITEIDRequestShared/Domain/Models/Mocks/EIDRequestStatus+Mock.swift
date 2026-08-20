#if DEBUG
import Foundation
@testable import BITCore

extension EIDRequestStatus: Mockable {
  struct Mock {

    static let inQueueSample: EIDRequestStatus = Mocker.decode(fromFile: "eid-request-status-queue", bundle: Bundle.module)
    static let readyForAVSample: EIDRequestStatus = Mocker.decode(fromFile: "eid-request-status-ready", bundle: Bundle.module)
    static let inWalletPairingSample: EIDRequestStatus = Mocker.decode(fromFile: "eid-request-status-wallet-pairing", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "eid-request-status-queue", bundle: Bundle.module) ?? Data()

    static let sampleAutoVerification = createSample(state: .autoVerification, targetWallets: EIDRequestStatus.TargetWallet(
      limitReached: false,
      pairedWallets: [
        EIDRequestStatus.TargetWallet.PairedWallet(
          pairedAt: Date(),
          walletPairingId: "walletPairingId_1"),
        EIDRequestStatus.TargetWallet.PairedWallet(
          pairedAt: Date(),
          walletPairingId: "walletPairingId_2"),
      ]))

    static let sampleAutoVerificationWithoutPairedWallets = createSample(
      state: .autoVerification,
      targetWallets: EIDRequestStatus.TargetWallet(limitReached: false, pairedWallets: []))

    static func createSample(
      state: EIDRequestStatus.State,
      onlineSessionStartCloseAt: Date? = nil,
      queueInformation: EIDRequestStatus.QueueInformation? = nil,
      legalRepresentant: EIDRequestStatus.LegalRepresentant? = nil,
      targetWallets: EIDRequestStatus.TargetWallet? = nil)
      -> EIDRequestStatus
    {
      EIDRequestStatus(
        state: state,
        onlineSessionStartCloseAt: onlineSessionStartCloseAt,
        queueInformation: queueInformation,
        legalRepresentant: legalRepresentant,
        targetWallets: targetWallets)
    }
  }
}
#endif
