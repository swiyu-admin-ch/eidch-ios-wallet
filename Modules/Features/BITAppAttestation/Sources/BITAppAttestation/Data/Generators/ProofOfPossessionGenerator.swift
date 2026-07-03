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
  func callAsFunction(
    for body: Encodable,
    audience: String?,
    challengeEndpoint: URL,
    clientAttestation: ClientAttestation,
    encoder: JSONEncoder) async throws
    -> ClientAttestationProofOfPossession
}

extension ProofOfPossessionGeneratorProtocol {
  public func callAsFunction(
    for body: Encodable,
    audience: String? = nil,
    challengeEndpoint: URL,
    clientAttestation: ClientAttestation,
    encoder: JSONEncoder = JSONEncoder()) async throws
    -> ClientAttestationProofOfPossession
  {
    try await callAsFunction(for: body, audience: audience, challengeEndpoint: challengeEndpoint, clientAttestation: clientAttestation, encoder: encoder)
  }
}

// MARK: - ProofOfPossessionGenerator

struct ProofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(
    for body: Encodable,
    audience: String?,
    challengeEndpoint: URL,
    clientAttestation: ClientAttestation,
    encoder: JSONEncoder) async throws
    -> ClientAttestationProofOfPossession
  {
    let challenge = try await fetchChallenge(challengeEndpoint)
    let clientAttestationKey = try appAttestationKeyRepository.get(for: .client)

    let canonicalizedBody = try jsonCanonicalizer.canonicalize(data: encoder.encode(body))
    let bodyHash = sha256Hasher.hash(canonicalizedBody).hexString

    let jwt = ClientAttestationProofOfPossessionJWT(
      expiredAt: Date().addingTimeInterval(300), // Must be current time + 5 min (cf. specifications)
      issuer: clientAttestation.payload.subject,
      jwtIdentifier: UUID().uuidString,
      audience: audience,
      requestBody: bodyHash,
      nonce: challenge,
      issuedAt: Date())

    return try jwsEncoder.encode(jwt, keyPair: clientAttestationKey)
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\NetworkContainer.urlSession) private var urlSession: URLSessionProtocol
  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol

  private func fetchChallenge(_ challengeEndpoint: URL) async throws -> AttestationChallenge {
    let (data, _) = try await urlSession.data(from: challengeEndpoint)
    return try JSONDecoder().decode(AttestationChallenge.Response.self, from: data).challenge
  }

}
