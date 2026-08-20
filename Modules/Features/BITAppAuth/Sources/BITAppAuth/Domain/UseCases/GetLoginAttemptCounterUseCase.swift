import Factory
import Foundation
import Spyable

// MARK: - GetLoginAttemptCounterUseCaseProtocol

@Spyable
public protocol GetLoginAttemptCounterUseCaseProtocol {
  func callAsFunction(kind: AuthMethod) throws -> Int
}

// MARK: - GetLoginAttemptCounterUseCase

struct GetLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocol {

  func callAsFunction(kind: AuthMethod) throws -> Int {
    try repository.getAttempts(kind: kind)
  }

  @Injected(\.loginRepository) private var repository: LoginRepositoryProtocol
}
