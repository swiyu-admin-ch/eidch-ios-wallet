import BITCrypto
import BITJsonCanonicalizer
import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - GenerateProofOfPossessionUseCaseProtocol

@Spyable
protocol GenerateProofOfPossessionUseCaseProtocol {
  func execute(for clientAttestation: ClientAttestation, challenge: AttestationChallenge, audience: String, body: Encodable, signingKey: KeyPair) async throws -> ClientAttestationProofOfPossession
}

// MARK: - GenerateProofOfPossessionUseCase

struct GenerateProofOfPossessionUseCase: GenerateProofOfPossessionUseCaseProtocol {

  // MARK: Internal

  func execute(for clientAttestation: ClientAttestation, challenge: AttestationChallenge, audience: String, body: Encodable, signingKey: KeyPair) async throws -> ClientAttestationProofOfPossession {
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

    return try jwsEncoder.encode(proofOfPossesionPayload, keyPair: signingKey)
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol
}
