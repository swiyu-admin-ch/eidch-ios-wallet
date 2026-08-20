import BITCore
import Factory
import Foundation
import Spyable

// MARK: - GetLockedWalletTimeLeftUseCaseProtocol

@Spyable
public protocol GetLockedWalletTimeLeftUseCaseProtocol {
  func callAsFunction() -> TimeInterval?
}

// MARK: - GetLockedWalletTimeLeftUseCase

struct GetLockedWalletTimeLeftUseCase: GetLockedWalletTimeLeftUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() -> TimeInterval? {
    guard let lockedTime = repository.getLockedWalletTimeInterval() else { return nil }
    let systemUptime = processInfoService.systemUptime
    let computedUnlockInterval = lockedTime + lockDelay
    return computedUnlockInterval - systemUptime
  }

  // MARK: Private

  @Injected(\.lockWalletRepository) private var repository: LockWalletRepositoryProtocol
  @Injected(\.processInfoService) private var processInfoService: ProcessInfoServiceProtocol
  @Injected(\.lockDelay) private var lockDelay: TimeInterval
}
