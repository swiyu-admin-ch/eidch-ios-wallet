import BITAnyCredentialFormat
import BITAppAttestation
import BITCredentialShared
import BITOca
import BITOpenID
import BITVault
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
    let metadataWrapper = try await fetchMetadataUseCase.execute(for: offer)
    let holderBindingContext = try await holderBindingContextGenerator.generate(from: metadataWrapper)
    let anyCredential: AnyCredential
    do {
      anyCredential = try await fetchAnyVerifiableCredentialUseCase.execute(from: offer, metadataWrapper: metadataWrapper, holderBindingContext: holderBindingContext)
    } catch {
      if let keyPair = holderBindingContext?.keyPair {
        try credentialKeyRepository.delete(keyPair)
      }
      throw error
    }
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(for: anyCredential)
    var credential = try credentialGenerator.generate(for: anyCredential, keyPair: holderBindingContext?.keyPair, rawOcaBundle: rawOcaBundle, metadataWrapper: metadataWrapper)
    let trustStatement = try? await fetchTrustStatementUseCase.execute(issuer: anyCredential.issuer)

    if let trustStatement {
      credential = try await updateCredentialIsserDisplays(credential: credential, with: trustStatement)
    }

    let savedCredential = try await credentialRepository.create(credential: credential)
    let updatedCredential = (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential

    return (updatedCredential, trustStatement)
  }

  // MARK: Private

  @Injected(\.fetchMetadataUseCase) private var fetchMetadataUseCase: FetchMetadataUseCaseProtocol
  @Injected(\.holderBindingContextGenerator) private var holderBindingContextGenerator: HolderBindingContextGeneratorProtocol
  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.fetchTrustStatementUseCase) private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocol
  @Injected(\.databaseCredentialRepository) private var credentialRepository: CredentialRepositoryProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol

  private func updateCredentialIsserDisplays(credential: Credential, with trustStatement: TrustStatement) async throws -> Credential {

    var credentialCopy = credential

    credentialCopy.issuerDisplays = credentialCopy.issuerDisplays.compactMap { issuerDisplay in
      guard
        let locale = issuerDisplay.locale,
        let localizedIssuerDisplay = trustStatement.localizedIssuer[locale] as? [String: Any]
      else {
        return nil
      }

      return CredentialIssuerDisplay(
        id: issuerDisplay.id,
        locale: issuerDisplay.locale,
        name: localizedIssuerDisplay["name"] as? String ?? issuerDisplay.name,
        credentialId: issuerDisplay.credentialId,
        image: issuerDisplay.image)
    }

    return credentialCopy
  }
}
