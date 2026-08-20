import BITQRCode
import Factory
import Foundation
import Spyable

// MARK: - FetchWalletPairingOfferUseCaseProtocol

@Spyable
protocol FetchWalletPairingOfferUseCaseProtocol {
  func execute(for caseId: String) async throws -> WalletPairingOffer
}

// MARK: - FetchWalletPairingOfferUseCase

struct FetchWalletPairingOfferUseCase: FetchWalletPairingOfferUseCaseProtocol {

  func execute(for caseId: String) async throws -> WalletPairingOffer {
    let pairingResponse = try await sidRepository.pairWallet(caseId: caseId)

    guard let qrCodeImageData = qrCodeGenerator.generate(from: pairingResponse.credentialOfferLink.absoluteString) else {
      throw FetchWalletPairingOfferUseCaseError.QRCodeGenerationFailed
    }

    return WalletPairingOffer(pairingId: pairingResponse.walletPairingId, credentialOfferLink: pairingResponse.credentialOfferLink, qrCodeImageData: qrCodeImageData)
  }

  @Injected(\.qrCodeGenerator) private var qrCodeGenerator
  @Injected(\.sidRepository) private var sidRepository
}

// MARK: - FetchWalletPairingOfferUseCaseError

enum FetchWalletPairingOfferUseCaseError: Error {
  case QRCodeGenerationFailed
}
