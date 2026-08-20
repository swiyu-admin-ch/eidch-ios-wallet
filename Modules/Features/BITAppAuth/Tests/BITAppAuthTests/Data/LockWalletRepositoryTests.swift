import Factory
import Foundation
import Testing
@testable import BITAppAuth
@testable import BITCore
@testable import BITTestingCore
@testable import BITVault

// MARK: - LockWalletRepositoryTests

@Suite
@MainActor
struct LockWalletRepositoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let secretManagerSpy = SecretManagerProtocolSpy()
    let keyManagerSpy = KeyManagerProtocolSpy()
    let processInfoServiceSpy = ProcessInfoServiceProtocolSpy()

    processInfoServiceSpy.systemUptime = Self.timeInterval

    Container.shared.secretManager.register { secretManagerSpy }
    Container.shared.keyManager.register { keyManagerSpy }
    Container.shared.processInfoService.register { processInfoServiceSpy }

    self.secretManagerSpy = secretManagerSpy
    repository = LockWalletRepository()
  }

  // MARK: Internal

  @Test
  func lockWallet_success() throws {
    try repository.lockWallet()

    #expect(secretManagerSpy.setForKeyQueryReceivedArguments?.key == Self.secretsKey)
    #expect(secretManagerSpy.setForKeyQueryReceivedArguments?.value as? Double == Self.timeInterval)
  }

  @Test
  func lockWallet_secretManagerThrowsError_throwsError() {
    secretManagerSpy.setForKeyQueryThrowableError = TestingError.error

    #expect(throws: TestingError.error) {
      try repository.lockWallet()
    }
  }

  @Test
  func unlockWallet_success() throws {
    try repository.unlockWallet()

    #expect(secretManagerSpy.removeObjectForKeyQueryReceivedArguments?.key == Self.secretsKey)
  }

  @Test
  func unlockWallet_secretManagerThrowsError_throwsError() {
    secretManagerSpy.removeObjectForKeyQueryThrowableError = TestingError.error

    #expect(throws: TestingError.error) {
      try repository.unlockWallet()
    }
  }

  @Test
  func getLockedWalletTimeInterval_exists_returnsInterval() throws {
    secretManagerSpy.doubleForKeyQueryReturnValue = Self.timeInterval

    let result = try repository.getLockedWalletTimeInterval()

    #expect(result == Self.timeInterval)
    #expect(!secretManagerSpy.removeObjectForKeyQueryCalled)
    #expect(!secretManagerSpy.setForKeyQueryCalled)
  }

  @Test
  func getLockedWalletTimeInterval_doesNotExist_returnsNil() throws {
    secretManagerSpy.doubleForKeyQueryReturnValue = nil

    let result = try repository.getLockedWalletTimeInterval()

    #expect(result == nil)
    #expect(!secretManagerSpy.removeObjectForKeyQueryCalled)
    #expect(!secretManagerSpy.setForKeyQueryCalled)
  }

  // MARK: Private

  private static let timeInterval: TimeInterval = 100
  private static let secretsKey = "lockedWalletUptime"

  private let secretManagerSpy: SecretManagerProtocolSpy
  private let repository: LockWalletRepositoryProtocol
}
