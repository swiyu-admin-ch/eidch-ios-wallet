import BITAnalytics
import BITAppAttestation
import BITAppAuth
import BITJWT
import BITLocalAuthentication
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - HolderBindingsGeneratorProtocol

@Spyable
protocol HolderBindingsGeneratorProtocol {
  func callAsFunction(from metadataWrapper: CredentialIssuerMetadataWrapper) async throws -> [HolderBinding]
}

// MARK: - HolderBindingsGenerator

struct HolderBindingsGenerator: HolderBindingsGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(from metadataWrapper: CredentialIssuerMetadataWrapper) async throws -> [HolderBinding] {
    guard let context = userSession.context else { return [] }
    let batchSize = if isBatchIssuanceEnabled {
      metadataWrapper.credentialIssuerMetadata.batchCredentialIssuance?.batchSize ?? 1
    } else {
      1
    }

    var bindings = [HolderBinding]()
    bindings.reserveCapacity(batchSize)

    for _ in 1...batchSize {
      if let nextBinding = try await generateHolderBinding(for: metadataWrapper, context: context) {
        bindings.append(nextBinding)
      } else {
        return []
      }
    }

    return bindings
  }

  // MARK: Private

  @Injected(\.preferredKeyBindingAlgorithmsOrdered) private var preferredKeyBindingAlgorithmsOrdered: [JWTAlgorithm]
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.supportedKeyStorageSecurityLevel) private var supportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel]
  @Injected(\.appAttestationRepository) private var appAttestationRepository: AppAttestationRepositoryProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.keyAttestationValidator) private var keyAttestationValidator: KeyAttestationValidatorProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.isBatchIssuanceEnabled) private var isBatchIssuanceEnabled

  private func generateHolderBinding(for metadataWrapper: CredentialIssuerMetadataWrapper, context: any LAContextProtocol) async throws -> HolderBinding? {
    guard let keyPair = try generateHolderBindingKeyPair(from: metadataWrapper) else { return nil }
    let keyAttestation: KeyAttestation? = try await {
      guard keyPair.options?.contains(.secureEnclave) == true else { return nil }
      return try await fetchKeyAttestation(for: keyPair, context: context)
    }()

    return HolderBinding(keyPair: keyPair, keyAttestationJWS: keyAttestation?.rawJWS)
  }

  private func generateHolderBindingKeyPair(from metadataWrapper: CredentialIssuerMetadataWrapper) throws -> VaultKeyPair? {
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

  private func fetchKeyAttestation(for keyPair: VaultKeyPair, context: LAContextProtocol) async throws -> KeyAttestation {
    let clientAttestation = try await clientAttestationRepository.get(using: context)
    let requestBody = try KeyAttestationRequestBody(keyPair: keyPair)
    let keyAttestation = try await appAttestationRepository.fetchKeyAttestation(body: requestBody, clientAttestation: clientAttestation)

    // Credential issuance requires locally validated key attestation before binding.
    guard await keyAttestationValidator(keyPair: keyPair, with: keyAttestation) else {
      throw AppAttestationRepositoryError.invalidKeyAttestation
    }

    return keyAttestation
  }
}
