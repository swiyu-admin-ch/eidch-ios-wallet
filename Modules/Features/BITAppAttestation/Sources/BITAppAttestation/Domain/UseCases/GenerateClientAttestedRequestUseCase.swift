import BITAppAuth
import BITCrypto
import Factory
import Spyable

// MARK: - GenerateClientAttestedRequestUseCaseProtocol

@Spyable
public protocol GenerateClientAttestedRequestUseCaseProtocol {
  func execute(for body: any ClientAttestedRequest.Body, challenge: AttestationChallenge, audience: String) async throws -> ClientAttestedRequest
}

// MARK: - GenerateClientAttestedRequestUseCase

struct GenerateClientAttestedRequestUseCase: GenerateClientAttestedRequestUseCaseProtocol {

  // MARK: Internal

  func execute(for body: any ClientAttestedRequest.Body, challenge: AttestationChallenge, audience: String) async throws -> ClientAttestedRequest {
    let clientAttestation = try await clientAttestationRepository.getClientAttestation()
    let clientAttestationKey = try appAttestationKeyRepository.getAttestionKey(for: .clientAttestation)

    let proofOfPossession = try await generateProofOfPossessionUseCase.execute(
      for: clientAttestation,
      challenge: challenge,
      audience: audience,
      body: body,
      signingKey: KeyPair(privateKey: clientAttestationKey))

    return ClientAttestedRequest(
      body: body,
      header: ClientAttestedRequest.Header(
        clientAttestation: clientAttestation.rawJWS,
        clientAttestationPoP: proofOfPossession.rawJWS))
  }

  // MARK: Private

  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol
  @Injected(\.generateProofOfPossessionUseCase) private var generateProofOfPossessionUseCase: GenerateProofOfPossessionUseCaseProtocol
}
