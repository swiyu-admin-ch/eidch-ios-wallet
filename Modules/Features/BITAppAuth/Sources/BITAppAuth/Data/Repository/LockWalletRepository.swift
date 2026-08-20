import BITCore
import BITVault
import Factory
import Foundation

// MARK: - LockWalletRepository

struct LockWalletRepository: LockWalletRepositoryProtocol {

  // MARK: Internal

  func getLockedWalletTimeInterval() -> TimeInterval? {
    secretManager.double(forKey: Key.lockedWalletUptime)
  }

  func lockWallet() throws {
    try secretManager.set(processInfoService.systemUptime, forKey: Key.lockedWalletUptime)
  }

  func unlockWallet() throws {
    try secretManager.removeObject(forKey: Key.lockedWalletUptime)
  }

  // MARK: Private

  private enum Key {
    static let lockedWalletUptime = "lockedWalletUptime"
  }

  @Injected(\.secretManager) private var secretManager: SecretManagerProtocol
  @Injected(\.processInfoService) private var processInfoService: ProcessInfoServiceProtocol
}
