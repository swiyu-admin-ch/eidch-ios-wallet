import BITCredentialShared
import Factory
import Spyable

// MARK: - RefreshCredentialsUseCaseProtocol

@Spyable
public protocol RefreshCredentialsUseCaseProtocol: Sendable {
  func callAsFunction() async throws -> [CredentialProtocol]
}

// MARK: - RefreshCredentialsUseCase

struct RefreshCredentialsUseCase: RefreshCredentialsUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() async throws -> [any CredentialProtocol] {
    let deferredCredentials = try await credentialRepository.getAllDeferredCredentials()
    try await refreshDeferredCredentialUseCase.execute(deferredCredentials)

    let verifiableCredentials = try await credentialRepository.getAllVerifiableCredentials()
    await refreshVerifiableCredentialsUseCase(verifiableCredentials)

    let refreshedVerifiableCredentials = try await credentialRepository.getAllVerifiableCredentials()
    try await checkAndUpdateCredentialStatusUseCase(refreshedVerifiableCredentials)

    return try await credentialRepository.getAll()
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProtocol
  @Injected(\.refreshDeferredCredentialUseCase) private var refreshDeferredCredentialUseCase: RefreshDeferredCredentialUseCaseProtocol
  @Injected(\.refreshVerifiableCredentialsUseCase) private var refreshVerifiableCredentialsUseCase: RefreshVerifiableCredentialsUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
}
