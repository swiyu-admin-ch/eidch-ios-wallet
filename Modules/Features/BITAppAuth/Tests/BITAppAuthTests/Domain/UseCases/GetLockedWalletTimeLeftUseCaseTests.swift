import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITCore
@testable import BITTestingCore

// MARK: - GetLockedWalletTimeLeftUseCaseTests

final class GetLockedWalletTimeLeftUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    useCase = GetLockedWalletTimeLeftUseCase()
    success()
  }

  func testExecute_systemUptimeEqualsLockTime_returnsDelay() {
    processInfoServiceSpy.systemUptime = lockTime

    let result = useCase.execute()

    XCTAssertEqual(result, delay)
  }

  func testExecute_systemUptimeInsideLockDelay_returnsDifferenceToDelay() {
    let difference = 2.0
    processInfoServiceSpy.systemUptime = lockTime + delay - difference

    let result = useCase.execute()

    XCTAssertEqual(result, difference)
  }

  func testExecute_systemUptimeRightOnLockDelay_returnsZero() {
    processInfoServiceSpy.systemUptime = lockTime + delay

    let result = useCase.execute()

    XCTAssertEqual(result, 0)
  }

  func testExecute_systemUptimeAfterLockDelay_returnsNegativeNumber() {
    processInfoServiceSpy.systemUptime = lockTime + 2 * delay

    let result = useCase.execute()

    XCTAssertEqual(result, -delay)
  }

  func testExecute_lockTimeNil_returnsNil() {
    lockWalletRepositorySpy.getLockedWalletTimeIntervalReturnValue = nil

    let result = useCase.execute()

    XCTAssertNil(result)
  }

  // MARK: Private

  private let lockTime: TimeInterval = 1000
  private let delay: TimeInterval = 5

  // swiftlint:disable all
  private var useCase: GetLockedWalletTimeLeftUseCase!
  private var lockWalletRepositorySpy: LockWalletRepositoryProtocolSpy!
  private var processInfoServiceSpy: ProcessInfoServiceProtocolSpy!

  // swiftlint:enable all

  private func registerMocks() {
    lockWalletRepositorySpy = LockWalletRepositoryProtocolSpy()
    processInfoServiceSpy = ProcessInfoServiceProtocolSpy()

    Container.shared.lockWalletRepository.register { self.lockWalletRepositorySpy }
    Container.shared.processInfoService.register { self.processInfoServiceSpy }
    Container.shared.lockDelay.register { self.delay }
  }

  private func success() {
    lockWalletRepositorySpy.getLockedWalletTimeIntervalReturnValue = lockTime
    processInfoServiceSpy.systemUptime = lockTime
  }

}
