import BITCredential
import BITCredentialShared
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - PairWalletUseCaseProtocol

@Spyable
protocol PairWalletUseCaseProtocol {
  @discardableResult
  func execute(for caseId: String) async throws -> String
}

// MARK: - PairWalletUseCase

struct PairWalletUseCase: PairWalletUseCaseProtocol {

  // MARK: Internal

  func execute(for caseId: String) async throws -> String {
    let walletPairingResponse = try await eIDRequestRepository.pairWallet(caseId: caseId)
    let credentialOffer = try validateCredentialOfferInvitationUrlUseCase.execute(walletPairingResponse.credentialOfferLink)
    let (credential, _) = try await fetchCredentialUseCase.execute(from: credentialOffer)

    guard let deferredCredential = credential as? DeferredCredential else {
      throw FetchCredentialUseCaseError.invalidCredential // Expect only a deferred credential here
    }

    var eIDRequestCase = try await eIDRequestCaseRepository.get(id: caseId)
    eIDRequestCase.deferredCredential = deferredCredential

    try await eIDRequestCaseRepository.update(eIDRequestCase)

    return walletPairingResponse.walletPairingId
  }

  // MARK: Private

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.fetchCredentialUseCase) private var fetchCredentialUseCase: FetchCredentialUseCaseProtocol
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
  @Injected(\.validateCredentialOfferInvitationUrlUseCase) private var validateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocol
}
