import Foundation

// MARK: - WalletPairingState

enum WalletPairingState: String, Decodable, Equatable {
  case open = "OPEN"
  case accepted = "ACCEPTED"
  case rejected = "REJECTED"
}

// MARK: - WalletPairingStateResponse

struct WalletPairingStateResponse: Decodable, Equatable {
  let state: WalletPairingState
}
