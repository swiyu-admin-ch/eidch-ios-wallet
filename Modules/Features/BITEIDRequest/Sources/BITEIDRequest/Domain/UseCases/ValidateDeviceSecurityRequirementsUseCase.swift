import BITAppAttestation
import BITLocalAuthentication
import BITNetworking
import BITVault
import Factory
import Spyable

// MARK: - ValidateDeviceSecurityRequirementsUseCaseProtocol

@Spyable
protocol ValidateDeviceSecurityRequirementsUseCaseProtocol {
  func callAsFunction(_ context: LAContextProtocol) async throws
}

// MARK: - ValidateDeviceSecurityRequirementsUseCase

/// Verifies device security requirements by ensuring valid client/key attestations
/// and validating them against the backend.
struct ValidateDeviceSecurityRequirementsUseCase: ValidateDeviceSecurityRequirementsUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ context: LAContextProtocol) async throws {
    do {
      let clientAttestation = try await clientAttestationRepository.get(using: context)
      let keyPair = try appAttestationKeyRepository.create(for: .key, with: context)
      let requestBody = try KeyAttestationRequestBody(keyPair: keyPair)
      let keyAttestation = try await attestationServiceRepository.fetchKeyAttestation(body: requestBody, clientAttestation: clientAttestation)

      guard await keyAttestationValidator(keyPair: keyPair, with: keyAttestation) else {
        throw SIDRepository.Error.invalidKeyAttestation
      }
      try await validateAttestationsUseCase.execute(clientAttestation: clientAttestation, keyAttestation: keyAttestation)
    } catch AttestationServiceRepositoryError.invalidClientAttestation {
      throw SIDRepository.Error.invalidClientAttestation
    } catch AttestationServiceRepositoryError.invalidKeyAttestation {
      throw SIDRepository.Error.invalidKeyAttestation
    } catch AttestationServiceRepositoryError.timeout {
      throw ValidateDeviceSecurityRequirementsUseCaseError.attestationTimeout
    } catch AttestationServiceRepositoryError.serviceDeactivated {
      throw ValidateDeviceSecurityRequirementsUseCaseError.attestationServiceDeactivated
    } catch is NetworkError {
      throw ValidateDeviceSecurityRequirementsUseCaseError.networkError
    } catch {
      throw error
    }
  }

  // MARK: Private

  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.attestationServiceRepository) private var attestationServiceRepository: AttestationServiceRepositoryProtocol
  @Injected(\.validateAttestationsUseCase) private var validateAttestationsUseCase: ValidateAttestationsUseCaseProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol
  @Injected(\.keyAttestationValidator) private var keyAttestationValidator: KeyAttestationValidatorProtocol
}

// MARK: - ValidateDeviceSecurityRequirementsUseCaseError

enum ValidateDeviceSecurityRequirementsUseCaseError: Error {
  case networkError
  case attestationTimeout
  case attestationServiceDeactivated
}
