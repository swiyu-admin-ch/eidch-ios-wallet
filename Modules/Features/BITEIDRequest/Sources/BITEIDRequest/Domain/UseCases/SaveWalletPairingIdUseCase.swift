import Factory
import Foundation
import Spyable

// MARK: - SaveWalletPairingIdUseCaseProtocol

@Spyable
protocol SaveWalletPairingIdUseCaseProtocol {
  func callAsFunction(_ pairingId: String, forRequestCase: String) async throws
}

// MARK: - SaveWalletPairingIdUseCase

struct SaveWalletPairingIdUseCase: SaveWalletPairingIdUseCaseProtocol {

  func callAsFunction(_ pairingId: String, forRequestCase: String) async throws {
    try await eIDRequestCaseRepository.savePairingId(pairingId, forRequestCaseId: forRequestCase)
  }

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}
