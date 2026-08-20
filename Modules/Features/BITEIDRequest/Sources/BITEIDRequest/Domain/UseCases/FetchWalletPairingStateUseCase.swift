import Factory
import Foundation
import Spyable

// MARK: - FetchWalletPairingStateUseCaseProtocol

@Spyable
protocol FetchWalletPairingStateUseCaseProtocol {
  func execute(for caseId: String, pairingId: String) async throws -> WalletPairingState
}

// MARK: - FetchWalletPairingStateUseCase

struct FetchWalletPairingStateUseCase: FetchWalletPairingStateUseCaseProtocol {

  func execute(for caseId: String, pairingId: String) async throws -> WalletPairingState {
    try await sidRepository.getPairingState(caseId: caseId, pairingId: pairingId)
  }

  @Injected(\.sidRepository) private var sidRepository
}
