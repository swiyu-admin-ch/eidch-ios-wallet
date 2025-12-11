import Foundation

struct WalletPairingResponse: Codable, Equatable {
  let walletPairingId: String
  let credentialOfferLink: URL
}
