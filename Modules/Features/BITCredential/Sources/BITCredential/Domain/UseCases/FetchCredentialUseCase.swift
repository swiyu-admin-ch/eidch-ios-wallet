import BITAnyCredentialFormat
import BITCredentialShared
import BITOca
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

  // MARK: Internal

  func execute(from offer: CredentialOffer) async throws -> (Credential, TrustStatement?) {
    let (metadataWrapper, anyCredential, keyPair) = try await fetchAnyVerifiableCredentialUseCase.execute(from: offer)
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(for: anyCredential)

    let credential = try credentialGenerator.generate(for: anyCredential, keyPair: keyPair, rawOcaBundle: rawOcaBundle, metadataWrapper: metadataWrapper)
    let savedCredential = try await credentialRepository.create(credential: credential)
    let updatedCredential = (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
    let trustStatement = try? await fetchTrustStatementUseCase.execute(issuer: anyCredential.issuer)

    return (updatedCredential, trustStatement)
  }

  // MARK: Private

  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.databaseCredentialRepository) private var credentialRepository: CredentialRepositoryProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.fetchTrustStatementUseCase) private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocol
}
