import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - FetchMetadataUseCaseProtocol

@Spyable
public protocol FetchMetadataUseCaseProtocol {
  func execute(from issuerUrl: URL) async throws -> NetworkResponse<CredentialMetadata>
}

// MARK: - FetchMetadataUseCase

struct FetchMetadataUseCase: FetchMetadataUseCaseProtocol {

  init(repository: OpenIDRepositoryProtocol = Container.shared.openIDRepository()) {
    self.repository = repository
  }

  private let repository: OpenIDRepositoryProtocol

  func execute(from issuerUrl: URL) async throws -> NetworkResponse<CredentialMetadata> {
    try await repository.fetchMetadata(from: issuerUrl)
  }
}
