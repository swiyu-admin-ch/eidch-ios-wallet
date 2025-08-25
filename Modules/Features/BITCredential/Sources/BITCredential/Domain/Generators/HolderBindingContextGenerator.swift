import BITAnalytics
import BITAppAttestation
import BITAppAuth
import BITJWT
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - HolderBindingContextGeneratorProtocol

@Spyable
protocol HolderBindingContextGeneratorProtocol {
  func generate(from metadataWrapper: CredentialMetadataWrapper) async throws -> HolderBindingContext?
}

// MARK: - HolderBindingContextGenerator

struct HolderBindingContextGenerator: HolderBindingContextGeneratorProtocol {

  // MARK: Internal

  func generate(from metadataWrapper: CredentialMetadataWrapper) async throws -> HolderBindingContext? {
    guard let context = userSession.context else { return nil }
    guard let keyPair = try generateHolderBindingKeyPair(from: metadataWrapper) else { return nil }
    let keyAttestation: KeyAttestation? = try await {
      guard keyPair.options?.contains(.secureEnclave) == true else { return nil }
      return try await fetchKeyAttestationUseCase.execute(for: keyPair, context)
    }()
    return HolderBindingContext(keyPair: keyPair, keyAttestationJWS: keyAttestation?.rawJWS)
  }

  // MARK: Private

  @Injected(\.preferredKeyBindingAlgorithmsOrdered) private var preferredKeyBindingAlgorithmsOrdered: [JWTAlgorithm]
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.supportedKeyStorageSecurityLevel) private var supportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel]
  @Injected(\.fetchKeyAttestationUseCase) private var fetchKeyAttestationUseCase: FetchKeyAttestationUseCaseProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.userSession) private var userSession: Session

  private func generateHolderBindingKeyPair(from metadataWrapper: CredentialMetadataWrapper) throws -> VaultKeyPair? {
    guard let proofType = metadataWrapper.selectedCredential.proofTypesSupported.first else {
      return nil
    }

    let supportedAlgorithms = proofType.algorithms
    let preferredAlgorithms = preferredKeyBindingAlgorithmsOrdered.map(\.rawValue)
    guard let algorithm = preferredAlgorithms.first(where: { supportedAlgorithms.contains($0) }) else {
      throw FetchAnyVerifiableCredentialError.unsupportedAlgorithm
    }

    let keyStorage = proofType.keyAttestationRequirements?.keyStorage ?? []
    guard keyStorage.contains(where: supportedKeyStorageSecurityLevel.contains) || keyStorage.isEmpty else {
      throw FetchAnyVerifiableCredentialError.unsupportedKeyStorage
    }

    let keyAttestationRequired = proofType.keyAttestationRequirements != nil

    do {
      return try credentialKeyRepository.create(algorithm: algorithm, isHardwareBound: keyAttestationRequired)
    } catch {
      analytics.log(error)
      throw error
    }
  }
}
