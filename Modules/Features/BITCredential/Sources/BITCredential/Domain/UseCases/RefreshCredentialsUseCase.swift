import BITCredentialShared
import Factory
import Spyable

// MARK: - RefreshCredentialsUseCaseProtocol

@Spyable
public protocol RefreshCredentialsUseCaseProtocol {
  func callAsFunction() async throws -> [CredentialProtocol]
}

// MARK: - RefreshCredentialsUseCase

struct RefreshCredentialsUseCase: RefreshCredentialsUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() async throws -> [any CredentialProtocol] {
    let deferredCredentials = try await credentialRepository.getAllDeferredCredentials()
    try await refreshDeferredCredentialUseCase.execute(deferredCredentials)

    let verifiableCredentials = try await credentialRepository.getAllVerifiableCredentials()
    try await checkAndUpdateCredentialStatusUseCase.execute(verifiableCredentials)

    return try await credentialRepository.getAll()
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol
  @Injected(\.refreshDeferredCredentialUseCase) private var refreshDeferredCredentialUseCase: RefreshDeferredCredentialUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
}
