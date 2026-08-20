import BITVault
import Factory
import Foundation
import Spyable

// MARK: - UnlockWalletUseCaseProtocol

@Spyable
public protocol UnlockWalletUseCaseProtocol {
  func callAsFunction() throws
}

// MARK: - UnlockWalletUseCase

struct UnlockWalletUseCase: UnlockWalletUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() throws {
    try repository.unlockWallet()
  }

  // MARK: Private

  @Injected(\.lockWalletRepository) private var repository: LockWalletRepositoryProtocol
}
