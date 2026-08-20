import Factory
import Foundation
import Spyable

// MARK: - CompareWalletPairingUseCaseProtocol

@Spyable
protocol CompareWalletPairingUseCaseProtocol {
  func callAsFunction(for caseId: String) async throws
}

// MARK: - CompareWalletPairingUseCase

struct CompareWalletPairingUseCase: CompareWalletPairingUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(for caseId: String) async throws {
    let status = try await sidRepository.fetchRequestStatus(for: caseId)

    guard
      let pairedWallets = status.targetWallets?.pairedWallets,
      !pairedWallets.isEmpty
    else {
      throw CompareWalletPairingUseCaseError.noDevicePaired
    }

    let savedPairingIds = try await eIDRequestCaseRepository.getPairingIds(forRequestCaseId: caseId)

    let remotePairingIds = Set(pairedWallets.map(\.walletPairingId))
    let localPairingIds = Set(savedPairingIds)

    guard remotePairingIds.isSubset(of: localPairingIds) else {
      throw CompareWalletPairingUseCaseError.invalidPairingCount
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.sidRepository) private var sidRepository: SIDRepositoryProtocol
  @ObservationIgnored @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}

// MARK: - CompareWalletPairingUseCaseError

enum CompareWalletPairingUseCaseError: Error {
  case invalidPairingCount
  case noDevicePaired
}
