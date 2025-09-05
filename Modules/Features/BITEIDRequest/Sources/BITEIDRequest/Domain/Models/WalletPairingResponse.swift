import Foundation

// MARK: - WalletPairingResponse

struct WalletPairingResponse: Codable, Equatable {
  let walletPairingId: String
  let credentialOfferLink: URL
}
