import Factory
import Foundation
import Spyable

// MARK: - IsUserLoggedInUseCaseProtocol

@Spyable
public protocol IsUserLoggedInUseCaseProtocol {
  func callAsFunction() -> Bool
}

// MARK: - IsUserLoggedInUseCase

struct IsUserLoggedInUseCase: IsUserLoggedInUseCaseProtocol {
  func callAsFunction() -> Bool {
    userSession.isLoggedIn
  }

  @Injected(\.userSession) private var userSession: Session
}
