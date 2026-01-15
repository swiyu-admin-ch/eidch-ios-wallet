public class AutoVerificationStateViewModel: WalletPairingStateViewModel {

  override func primaryAction() {
    delegate?.didTapIdentityCheck(caseId: id)
  }
}
