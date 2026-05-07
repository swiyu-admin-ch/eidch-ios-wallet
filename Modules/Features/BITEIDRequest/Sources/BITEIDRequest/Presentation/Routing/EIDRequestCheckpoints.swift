import NavigatorUI

struct EIDRequestCheckpoints: NavigationCheckpoints {

  static var start: NavigationCheckpoint<Void> {
    checkpoint()
  }

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
