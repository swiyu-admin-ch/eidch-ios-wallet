import BITCredentialShared
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - FetchCredentialUseCaseProtocol

@Spyable
public protocol FetchCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer) async throws -> (Credential, TrustStatement?)
}

// MARK: - FetchCredentialUseCase

struct FetchCredentialUseCase: FetchCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer) async throws -> (Credential, TrustStatement?) {
    let (metadataWrapper, credential, keyPair, ocaBundle) = try await fetchAnyVerifiableCredentialUseCase.execute(from: offer)


    let savedCredential = try await saveCredentialUseCase.execute(credential: credential, keyPair: keyPair, metadataWrapper: metadataWrapper)
    let updatedCredential = (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
    let trustStatement = try? await fetchTrustStatementUseCase.execute(issuer: credential.issuer)

    return (updatedCredential, trustStatement)
  }

  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.saveCredentialUseCase) private var saveCredentialUseCase: SaveCredentialUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.fetchTrustStatementUseCase) private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocol
}
