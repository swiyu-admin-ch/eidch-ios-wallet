import BITAnyCredentialFormat
import BITOca
import Factory
import Spyable

// MARK: - FetchAnyCredentialUseCaseProtocol

@Spyable
protocol FetchAnyCredentialUseCaseProtocol {
  func execute(for context: FetchCredentialContext) async throws -> (credential: AnyCredential, ocaBundle: RawOcaBundle?)
}

// MARK: - FetchAnyCredentialUseCase

struct FetchAnyCredentialUseCase: FetchAnyCredentialUseCaseProtocol {

  func execute(for context: FetchCredentialContext) async throws -> (credential: AnyCredential, ocaBundle: RawOcaBundle?) {
    guard let credentialFormat = CredentialFormat(rawValue: context.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    return try await dispatcherFormat.execute(for: context)
  }

  @Injected(\.anyFetchCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]
}
