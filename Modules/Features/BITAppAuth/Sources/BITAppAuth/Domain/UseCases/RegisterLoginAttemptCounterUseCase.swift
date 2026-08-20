import Factory
import Foundation
import Spyable

// MARK: - RegisterLoginAttemptCounterUseCaseProtocol

@Spyable
public protocol RegisterLoginAttemptCounterUseCaseProtocol {
  @discardableResult
  func callAsFunction(kind: AuthMethod) throws -> Int
}

// MARK: - RegisterLoginAttemptCounterUseCase

struct RegisterLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocol {

  @discardableResult
  func callAsFunction(kind: AuthMethod) throws -> Int {
    let value = try repository.getAttempts(kind: kind) + 1
    return try repository.registerAttempt(value, kind: kind)
  }

  @Injected(\.loginRepository) private var repository: LoginRepositoryProtocol
}
