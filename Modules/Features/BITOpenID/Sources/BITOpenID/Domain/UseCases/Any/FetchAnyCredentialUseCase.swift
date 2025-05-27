import BITAnyCredentialFormat
import BITOca
import Factory
import Spyable

// MARK: - FetchAnyCredentialUseCaseProtocol

@Spyable
protocol FetchAnyCredentialUseCaseProtocol {
  func execute(for context: FetchCredentialContext) async throws -> AnyCredential
}

// MARK: - FetchAnyCredentialUseCase

struct FetchAnyCredentialUseCase: FetchAnyCredentialUseCaseProtocol {

  func execute(for context: FetchCredentialContext) async throws -> AnyCredential {
    guard let credentialFormat = CredentialFormat(rawValue: context.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    return try await dispatcherFormat.execute(for: context)
  }

  @Injected(\.anyFetchCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]
}
