import BITVault
import Factory
import Foundation
import Spyable

// MARK: - LockWalletUseCaseProtocol

@Spyable
public protocol LockWalletUseCaseProtocol {
  func callAsFunction() throws
}

// MARK: - LockWalletUseCase

struct LockWalletUseCase: LockWalletUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() throws {
    try repository.lockWallet()
  }

  // MARK: Private

  @Injected(\.lockWalletRepository) private var repository: LockWalletRepositoryProtocol
}

// MARK: - MockLockWalletUseCase

#if DEBUG || targetEnvironment(simulator)
struct MockLockWalletUseCase: LockWalletUseCaseProtocol {
  func callAsFunction() throws {}
}
#endif
