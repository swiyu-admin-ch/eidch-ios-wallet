import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import Factory
import Spyable

// MARK: - FetchCredentialUseCaseProtocol

@Spyable
public protocol FetchCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer) async throws -> FetchCredentialResult
}

// MARK: - FetchCredentialUseCase

struct FetchCredentialUseCase: FetchCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from offer: CredentialOffer) async throws -> FetchCredentialResult {
    let metadataWrapper = try await fetchMetadataUseCase.execute(for: offer)
    let holderBindingContext = try await holderBindingContextGenerator.generate(from: metadataWrapper)
    let anyCredential: AnyCredential

    do {
      let result = try await fetchAnyVerifiableCredentialUseCase.execute(from: offer, metadataWrapper: metadataWrapper, holderBindingContext: holderBindingContext)

      switch result {
      case .credential(let credential):
        anyCredential = credential
      case .deferred(let transactionId, let accessToken, let endpoint, let format):
        return .deferred(DeferredCredential(transactionId: transactionId, accessToken: accessToken, endpoint: endpoint, format: format))
      }
    } catch {
      if let keyPair = holderBindingContext?.keyPair {
        try credentialKeyRepository.delete(keyPair)
      }
      throw error
    }

    return try await generateCredential(from: anyCredential, metadata: metadataWrapper, holderBindingContext: holderBindingContext)
  }

  // MARK: Private

  @Injected(\.fetchMetadataUseCase) private var fetchMetadataUseCase: FetchMetadataUseCaseProtocol
  @Injected(\.holderBindingContextGenerator) private var holderBindingContextGenerator: HolderBindingContextGeneratorProtocol
  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.verifiableCredentialRepository) private var verifiableCredentialRepository
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol

  private func updateCredentialIssuerDisplays(credential: VerifiableCredential, with trustStatement: any LocalizedTrustStatement) async throws -> VerifiableCredential {
    var credentialCopy = credential

    credentialCopy.issuerDisplays = credentialCopy.issuerDisplays.compactMap { issuerDisplay in
      guard let locale = issuerDisplay.locale else { return nil }
      let entityNames = trustStatement.entityNames
      return CredentialIssuerDisplay(
        id: issuerDisplay.id,
        locale: issuerDisplay.locale,
        name: entityNames[locale] ?? issuerDisplay.name,
        credentialId: issuerDisplay.credentialId,
        image: issuerDisplay.image)
    }

    return credentialCopy
  }

  private func generateCredential(from anyCredential: AnyCredential, metadata: CredentialMetadataWrapper, holderBindingContext: HolderBindingContext?) async throws -> FetchCredentialResult {
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(for: anyCredential)
    var credential = try credentialGenerator.generate(for: anyCredential, keyPair: holderBindingContext?.keyPair, rawOcaBundle: rawOcaBundle, metadataWrapper: metadata)
    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)

    if case .trusted(let trustStatement) = trustInformation.identity {
      credential = try await updateCredentialIssuerDisplays(credential: credential, with: trustStatement)
    }

    let savedCredential = try await verifiableCredentialRepository.create(credential)
    let updatedCredential = (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
    return .credential(updatedCredential, trustInformation)
  }
}

// MARK: - FetchCredentialUseCaseError

public enum FetchCredentialUseCaseError: Error {
  case invalidCredential
  case deferredCredentialNotSupported
}
