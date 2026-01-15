import BITActivity
import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - FetchCredentialUseCaseProtocol

@Spyable
public protocol FetchCredentialUseCaseProtocol {
  func execute(from offer: CredentialOffer) async throws -> (CredentialProtocol, TrustInformation?)
}

// MARK: - FetchCredentialUseCase

struct FetchCredentialUseCase: FetchCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from offer: CredentialOffer) async throws -> (CredentialProtocol, TrustInformation?) {
    let metadataWrapper = try await fetchMetadataUseCase.execute(for: offer)
    let holderBindingContext = try await holderBindingContextGenerator.generate(from: metadataWrapper)
    let anyCredential: AnyCredential

    do {
      let result = try await fetchAnyVerifiableCredentialUseCase.execute(from: offer, metadataWrapper: metadataWrapper, holderBindingContext: holderBindingContext)

      switch result {
      case .credential(let credential):
        anyCredential = credential
      case .deferred(let deferredCredentialRequest):
        let deferredCredential = try await generateDeferredCredential(from: deferredCredentialRequest, metadata: metadataWrapper, holderBindingContext: holderBindingContext)
        return (deferredCredential, nil)
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

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.fetchMetadataUseCase) private var fetchMetadataUseCase: FetchMetadataUseCaseProtocol
  @Injected(\.holderBindingContextGenerator) private var holderBindingContextGenerator: HolderBindingContextGeneratorProtocol
  @Injected(\.fetchAnyVerifiableCredentialUseCase) private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocol
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.fetchVcMetadataUseCase) private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol
  @Injected(\.credentialGenerator) private var credentialGenerator: CredentialGeneratorProtocol
  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.activityService) private var activityService

  private func updateCredentialIssuerDisplays(credential: VerifiableCredential, with trustStatement: IdentityTrustStatementJWT) async throws -> VerifiableCredential {
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

  private func generateCredential(from anyCredential: AnyCredential, metadata: CredentialMetadataWrapper, holderBindingContext: HolderBindingContext?) async throws -> (VerifiableCredential, TrustInformation?) {
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(anyCredential: anyCredential)
    let keyBinding = try createKeyBinding(from: holderBindingContext?.keyPair)

    var credential = try credentialGenerator.generate(for: anyCredential, keyBinding: keyBinding, rawOcaBundle: rawOcaBundle, metadataWrapper: metadata)
    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)

    if case .trusted(let trustStatement) = trustInformation.identity {
      credential = try await updateCredentialIssuerDisplays(credential: credential, with: trustStatement)
    }

    let savedCredential = try await credentialRepository.create(verifiableCredential: credential)
    let activity = Activity(credential: savedCredential, trustInformation: trustInformation)
    _ = try? activityService.create(activity, credentialId: savedCredential.id)
    let updatedCredential = (try? await checkAndUpdateCredentialStatusUseCase.execute(for: savedCredential)) ?? savedCredential
    return (updatedCredential, trustInformation)
  }

  private func generateDeferredCredential(from deferredCredentialRequest: DeferredCredentialRequest, metadata: CredentialMetadataWrapper, holderBindingContext: HolderBindingContext?) async throws -> DeferredCredential {
    let rawOcaBundle = try await fetchVcMetadataUseCase.execute(metadata: metadata.selectedCredential)
    let keyBinding = try createKeyBinding(from: holderBindingContext?.keyPair)

    return try credentialGenerator.generateDeferred(deferredCredentialRequest, keyBinding: keyBinding, rawOcaBundle: rawOcaBundle, metadataWrapper: metadata)
  }

  private func createKeyBinding(from keyPair: VaultKeyPair?) throws -> CredentialKeyBinding? {
    try keyPair.flatMap { keyPair in
      let isHardwareKey = keyPair.options?.contains(.secureEnclave) ?? false
      let (publicKey, privateKey): (Data?, Data?) = isHardwareKey
        ? (nil, nil)
        : try keyManager.getExternalRepresentation(of: keyPair.privateKey)

      return CredentialKeyBinding(
        id: UUID(uuidString: keyPair.identifier) ?? UUID(),
        algorithm: keyPair.algorithm.rawValue,
        bindingType: isHardwareKey ? .hardware : .software,
        publicKey: publicKey,
        privateKey: privateKey)
    }
  }
}

// MARK: - FetchCredentialUseCaseError

public enum FetchCredentialUseCaseError: Error {
  case invalidCredential
}
