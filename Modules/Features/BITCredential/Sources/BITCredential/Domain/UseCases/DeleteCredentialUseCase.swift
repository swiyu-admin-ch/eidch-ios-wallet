import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - DeleteCredentialUseCaseProtocol

@Spyable
public protocol DeleteCredentialUseCaseProtocol {
  func execute(_ credential: CredentialProtocol) async throws
}

// MARK: - DeleteCredentialUseCase

struct DeleteCredentialUseCase: DeleteCredentialUseCaseProtocol {

  func execute(_ credential: CredentialProtocol) async throws {
    try await credentialRepository.delete(credential.id)
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository

}
