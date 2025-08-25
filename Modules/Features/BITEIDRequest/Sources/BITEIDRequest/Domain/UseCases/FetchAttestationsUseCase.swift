import BITAppAttestation
import BITAppAuth
import BITLocalAuthentication
import BITNetworking
import Factory
import Spyable

// MARK: - FetchAttestationsUseCaseProtocol

@Spyable
protocol FetchAttestationsUseCaseProtocol {
  func execute(_ context: LAContextProtocol) async throws
}

// MARK: - FetchAttestationsUseCase

struct FetchAttestationsUseCase: FetchAttestationsUseCaseProtocol {

  // MARK: Internal

  func execute(_ context: LAContextProtocol) async throws {
    do {
      let clientAttestation = try await fetchClientAttestationUseCase.execute(context)
      let keyPair = try appAttestationKeyRepository.create(for: .key, with: context)
      let keyAttestation = try await fetchKeyAttestationUseCase.execute(for: keyPair, context)
      try await validateAttestationsUseCase.execute(clientAttestation: clientAttestation, keyAttestation: keyAttestation)
    } catch is NetworkError {
      throw FetchAttestationsUseCaseError.networkError
    } catch {
      throw error
    }
  }

  // MARK: Private

  @Injected(\.fetchClientAttestationUseCase) private var fetchClientAttestationUseCase: FetchClientAttestationUseCaseProtocol
  @Injected(\.fetchKeyAttestationUseCase) private var fetchKeyAttestationUseCase: FetchKeyAttestationUseCaseProtocol
  @Injected(\.validateAttestationsUseCase) private var validateAttestationsUseCase: ValidateAttestationsUseCaseProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol
}

// MARK: - FetchAttestationsUseCaseError

enum FetchAttestationsUseCaseError: Error {
  case networkError
}
