import BITAppAttestation
import BITLocalAuthentication
import Factory
import Spyable

// MARK: - ValidateAttestationsUseCaseProtocol

@Spyable
public protocol ValidateAttestationsUseCaseProtocol {
  func execute(clientAttestation: ClientAttestation, keyAttestation: KeyAttestation) async throws
}

// MARK: - ValidateAttestationsUseCase

struct ValidateAttestationsUseCase: ValidateAttestationsUseCaseProtocol {

  // MARK: Internal

  func execute(clientAttestation: ClientAttestation, keyAttestation: KeyAttestation) async throws {
    let requestBody = ValidateAttestationsRequestBody(clientAttestation: clientAttestation.rawJWS, keyAttestation: keyAttestation.rawJWS)
    try await eIDRequestRepository.validateAttestations(requestBody)
  }

  // MARK: Private

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
}
