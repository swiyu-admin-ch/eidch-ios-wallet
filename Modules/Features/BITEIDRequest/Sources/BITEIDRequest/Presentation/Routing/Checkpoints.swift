import NavigatorUI

struct EIDRequestCheckpoints: NavigationCheckpoints {
  static var walletPairingOffer: NavigationCheckpoint<Void> { checkpoint() }
}
