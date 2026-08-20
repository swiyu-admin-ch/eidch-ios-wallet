import Factory
import Foundation
import Spyable

// MARK: - ResetLoginAttemptCounterUseCaseProtocol

@Spyable
public protocol ResetLoginAttemptCounterUseCaseProtocol {
  func callAsFunction() throws
  func callAsFunction(kind: AuthMethod) throws
}

// MARK: - ResetLoginAttemptCounterUseCase

struct ResetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol {

  func callAsFunction() throws {
    for kind in AuthMethod.allCases {
      try repository.resetAttempts(kind: kind)
    }
  }

  func callAsFunction(kind: AuthMethod) throws {
    try repository.resetAttempts(kind: kind)
  }

  @Injected(\.loginRepository) private var repository: LoginRepositoryProtocol
}
