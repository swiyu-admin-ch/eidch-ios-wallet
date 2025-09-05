import Foundation

// MARK: - WalletPairingOffer

struct WalletPairingOffer {
  var pairingId: String
  var credentialOfferLink: URL
  var qrCodeImageData: Data
}
