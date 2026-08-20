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
  func callAsFunction(batchSize: Int?, proofTypes: [CredentialIssuerMetadata.ProofType]) async throws -> [HolderBinding]
}

// MARK: - HolderBindingsGenerator

struct HolderBindingsGenerator: HolderBindingsGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(batchSize: Int?, proofTypes: [CredentialIssuerMetadata.ProofType]) async throws -> [HolderBinding] {
    guard let context = userSession.context else { return [] }
    var batchSize = isBatchIssuanceEnabled ? batchSize ?? 1 : 1
    batchSize = min(batchSize, Self.maxBatchSize)

    guard batchSize > 0 else { return [] }
    guard let proofType = proofTypes.first else { return [] }

    var keyPairs = [VaultKeyPair]()
    keyPairs.reserveCapacity(batchSize)

    do {
      for _ in 0..<batchSize {
        try keyPairs.append(generateHolderBindingKeyPair(proofType: proofType))
      }

      return try await generateHolderBindings(for: keyPairs, context: context)
    } catch {
      deleteKeyPairs(keyPairs)
      throw error
    }
  }

  // MARK: Private

  private static let maxBatchSize = 100

  @Injected(\.preferredKeyBindingAlgorithmsOrdered) private var preferredKeyBindingAlgorithmsOrdered: [JWTAlgorithm]
  @Injected(\.credentialKeyRepository) private var credentialKeyRepository: CredentialKeyRepositoryProtocol
  @Injected(\.supportedKeyStorageSecurityLevel) private var supportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel]
  @Injected(\.attestationServiceRepository) private var attestationServiceRepository: AttestationServiceRepositoryProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.keyAttestationValidator) private var keyAttestationValidator: KeyAttestationValidatorProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.isBatchIssuanceEnabled) private var isBatchIssuanceEnabled

  private func generateHolderBindings(for keyPairs: [VaultKeyPair], context: LAContextProtocol) async throws -> [HolderBinding] {
    let keyAttestations = try await fetchKeyAttestationBatch(for: keyPairs, context: context)

    return zip(keyPairs, keyAttestations).map { keyPair, keyAttestation in
      HolderBinding(keyPair: keyPair, keyAttestationJWS: keyAttestation?.rawJWS)
    }
  }

  private func generateHolderBindingKeyPair(proofType: CredentialIssuerMetadata.ProofType) throws -> VaultKeyPair {
    let supportedAlgorithms = proofType.algorithms
    let preferredAlgorithms = preferredKeyBindingAlgorithmsOrdered.map(\.rawValue)
    guard let algorithm = preferredAlgorithms.first(where: { supportedAlgorithms.contains($0) }) else {
      throw FetchAnyVerifiableCredentialError.unsupportedAlgorithm
    }

    let keyStorage = proofType.keyAttestationRequirements?.keyStorage ?? []
    guard keyStorage.contains(where: supportedKeyStorageSecurityLevel.contains) || keyStorage.isEmpty else {
      throw FetchAnyVerifiableCredentialError.unsupportedKeyStorage
    }

    let isKeyAttestationRequired = proofType.keyAttestationRequirements != nil

    do {
      return try credentialKeyRepository.create(algorithm: algorithm, isHardwareBound: isKeyAttestationRequired)
    } catch {
      analytics.log(error)
      throw error
    }
  }

  private func fetchKeyAttestation(for keyPair: VaultKeyPair, clientAttestation: ClientAttestation) async throws -> KeyAttestation {
    let requestBody = try KeyAttestationRequestBody(keyPair: keyPair)
    let keyAttestation = try await attestationServiceRepository.fetchKeyAttestation(body: requestBody, clientAttestation: clientAttestation)

    guard await keyAttestationValidator(keyPair: keyPair, with: keyAttestation) else {
      throw AttestationServiceRepositoryError.invalidKeyAttestation
    }

    return keyAttestation
  }

  private func fetchKeyAttestationBatch(for keyPairs: [VaultKeyPair], context: LAContextProtocol) async throws -> [KeyAttestation?] {
    var keyAttestations = [KeyAttestation?](repeating: nil, count: keyPairs.count)
    let hardwareBoundedKeyPairs = keyPairs.indices.filter {
      keyPairs[$0].options?.contains(.secureEnclave) == true
    }

    if hardwareBoundedKeyPairs.isEmpty {
      return keyAttestations
    }

    let clientAttestation = try await clientAttestationRepository.get(using: context)

    if hardwareBoundedKeyPairs.count == 1, let index = hardwareBoundedKeyPairs.first {
      keyAttestations[index] = try await fetchKeyAttestation(for: keyPairs[index], clientAttestation: clientAttestation)
      return keyAttestations
    }

    let requestBody = try hardwareBoundedKeyPairs.map { index in
      try KeyAttestationRequestBody(keyPair: keyPairs[index])
    }

    let fetchedKeyAttestations = try await attestationServiceRepository.fetchBatchKeyAttestation(body: requestBody, clientAttestation: clientAttestation)

    guard fetchedKeyAttestations.count == hardwareBoundedKeyPairs.count else {
      throw AttestationServiceRepositoryError.invalidKeyAttestation
    }

    for (index, keyAttestation) in zip(hardwareBoundedKeyPairs, fetchedKeyAttestations) {
      guard await keyAttestationValidator(keyPair: keyPairs[index], with: keyAttestation) else {
        throw AttestationServiceRepositoryError.invalidKeyAttestation
      }

      keyAttestations[index] = keyAttestation
    }

    return keyAttestations
  }

  private func deleteKeyPairs(_ keyPairs: [VaultKeyPair]) {
    do {
      try keyPairs.forEach { try credentialKeyRepository.delete($0) }
    } catch {
      analytics.log(error)
    }
  }
}
