import BITCredential
import Factory
import Foundation
import Spyable

// MARK: - GetCredentialsCountUseCaseProtocol

@Spyable
protocol GetCredentialsCountUseCaseProtocol {
  func callAsFunction() async throws -> Int
}

// MARK: - GetCredentialsCountUseCase

struct GetCredentialsCountUseCase: GetCredentialsCountUseCaseProtocol {

  /// We async/await the call event though repository.count() is synchronous to avoid DB access crashes
  func callAsFunction() async throws -> Int {
    try await credentialRepository.count()
  }

  @Injected(\.credentialRepository) private var credentialRepository
}
