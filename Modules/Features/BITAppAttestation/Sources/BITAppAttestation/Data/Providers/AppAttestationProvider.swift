import BITCore
import BITCrypto
import BITJsonCanonicalizer
import DeviceCheck
import Factory
import Spyable

// MARK: - AppAttestationProviderProtocol

@Spyable
protocol AppAttestationProviderProtocol {

  /// Create a key pair in the Secure Enclave with the DeviceCheck framework, then request Apple to attest of its validity
  ///
  ///  Requires a challenge in order to reduce the risk of replay attacks
  ///
  /// - Parameters:
  ///   - challenge: One time challenge receive from the server
  ///
  /// - Returns: AttestedKey to be used for generateAppAssertion and in the client attestation request
  func generateAttestedKey(with challenge: AttestationChallenge) async throws -> AppAttestedKey

  /// Generate an assertion to attest of the integrity of the app for the server
  ///
  /// - Parameters:
  ///   - key: Identifier of an attested key generated with generateAttestedKey
  ///   - clientDataObject: Attestations service request containing the challenge and binding key
  ///
  /// - Returns: Assertion object to be used in the client attestation request
  func generateAppAssertion(for key: String, with clientDataObject: ClientDataObject) async throws -> AppAssertion
}

// MARK: - AppAttestationProvider

struct AppAttestationProvider: AppAttestationProviderProtocol {

  // MARK: Internal

  func generateAttestedKey(with challenge: AttestationChallenge) async throws -> AppAttestedKey {
    if !deviceCheckAppAttestService.isSupported {
      throw AppAttestationProviderError.unsupportedDevice
    }

    let keyIdentifier = try await deviceCheckAppAttestService.generateKey()

    guard let challengeData = challenge.data(using: .utf8) else {
      throw AppAttestationProviderError.invalidChallenge
    }

    let challengeHash = sha256Hasher.hash(challengeData)
    let clientData = try await deviceCheckAppAttestService.attestKey(keyIdentifier, clientDataHash: challengeHash)

    return AppAttestedKey(clientData: clientData, identifier: keyIdentifier)
  }

  func generateAppAssertion(for key: String, with clientDataObject: ClientDataObject) async throws -> AppAssertion {
    if !deviceCheckAppAttestService.isSupported {
      throw AppAttestationProviderError.unsupportedDevice
    }

    let clientData = try JSONEncoder(outputFormatting: [.sortedKeys]).encode(clientDataObject)
    let canonicalizedClientData = try jsonCanonicalizer.canonicalize(data: clientData)
    let clientDataHash = sha256Hasher.hash(canonicalizedClientData)

    return try await deviceCheckAppAttestService.generateAssertion(key, clientDataHash: clientDataHash)
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol
  @Injected(\.deviceCheckAppAttestService) private var deviceCheckAppAttestService: DeviceCheckAppAttestServiceProtocol
}

// MARK: - AppAttestationProviderError

enum AppAttestationProviderError: Error {
  case invalidChallenge
  case invalidRequest
  case unsupportedDevice
}
