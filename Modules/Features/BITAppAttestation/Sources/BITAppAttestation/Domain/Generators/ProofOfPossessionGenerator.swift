import BITCrypto
import BITJsonCanonicalizer
import BITJWT
import BITNetworking
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - ProofOfPossessionGeneratorProtocol

@Spyable
public protocol ProofOfPossessionGeneratorProtocol {
  func generate(for body: Encodable, audience: String, challengeEndpoint: URL) async throws -> (clientAttestation: ClientAttestation, proofOfPossesion: ClientAttestationProofOfPossession)
}

// MARK: - ProofOfPossessionGenerator

struct ProofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol {

  // MARK: Internal

  func generate(for body: Encodable, audience: String, challengeEndpoint: URL) async throws -> (clientAttestation: ClientAttestation, proofOfPossesion: ClientAttestationProofOfPossession) {
    let challenge = try await fetchChallenge(challengeEndpoint)
    let clientAttestation = try await clientAttestationRepository.get()
    let clientAttestationKey = try appAttestationKeyRepository.get(for: .client)

    let canonicalizedBody = try jsonCanonicalizer.canonicalize(data: JSONEncoder().encode(body))
    let bodyHash = sha256Hasher.hash(canonicalizedBody).hexString

    let proofOfPossesionPayload = ClientAttestationProofOfPossessionPayload(
      expiredAt: Date().addingTimeInterval(300), // Must be current time + 5 min (cf. specifications)
      issuer: clientAttestation.payload.subject,
      jwtIdentifier: UUID().uuidString,
      audience: audience,
      requestBody: bodyHash,
      nonce: challenge,
      issuedAt: Date())

    let proofOfPossession = try jwsEncoder.encode(proofOfPossesionPayload, keyPair: clientAttestationKey)

    return (clientAttestation: clientAttestation, proofOfPossesion: proofOfPossession)
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\NetworkContainer.urlSession) private var urlSession: URLSessionProtocol
  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol

  private func fetchChallenge(_ challengeEndpoint: URL) async throws -> AttestationChallenge {
    let (data, _) = try await urlSession.data(from: challengeEndpoint)
    return try JSONDecoder().decode(AttestationChallenge.Response.self, from: data).challenge
  }

}
