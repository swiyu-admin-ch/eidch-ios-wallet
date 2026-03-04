import NavigatorUI

struct EIDRequestCheckpoints: NavigationCheckpoints {
  static var walletPairingOffer: NavigationCheckpoint<Void> {
    checkpoint()
  }

  static var scanDocumentInformation: NavigationCheckpoint<Void> {
    checkpoint()
  }

  static var recordDocumentInformation: NavigationCheckpoint<Void> {
    checkpoint()
  }

  static var recordSelfieInformation: NavigationCheckpoint<Void> {
    checkpoint()
  }
}
