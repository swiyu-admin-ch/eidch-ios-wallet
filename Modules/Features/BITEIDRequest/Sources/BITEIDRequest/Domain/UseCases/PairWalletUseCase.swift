import BITCredential
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - PairWalletUseCaseProtocol

@Spyable
protocol PairWalletUseCaseProtocol {
  func execute(for caseId: String) async throws
}

// MARK: - PairWalletUseCase

struct PairWalletUseCase: PairWalletUseCaseProtocol {

  // MARK: Internal

  func execute(for caseId: String) async throws {
    let credentialOfferLink = try await eIDRequestRepository.pairWallet(caseId: caseId).credentialOfferLink
    let credentialOffer = try validateCredentialOfferInvitationUrlUseCase.execute(credentialOfferLink)
    let fetchCredentialResult = try await fetchCredentialUseCase.execute(from: credentialOffer)

    guard case .deferred(let deferredCredential) = fetchCredentialResult else {
      throw FetchCredentialUseCaseError.invalidCredential // Expect only a deferred credential here
    }

    try await deferredCredentialRepository.create(deferredCredential)
  }

  // MARK: Private

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.fetchCredentialUseCase) private var fetchCredentialUseCase: FetchCredentialUseCaseProtocol
  @Injected(\.deferredCredentialRepository) private var deferredCredentialRepository: DeferredCredentialRepositoryProtocol
  @Injected(\.validateCredentialOfferInvitationUrlUseCase) private var validateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocol
}
