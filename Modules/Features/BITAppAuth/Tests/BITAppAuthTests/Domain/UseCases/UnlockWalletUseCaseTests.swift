import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

// MARK: - UnlockWalletUseCaseTests

final class UnlockWalletUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    useCase = UnlockWalletUseCase()
  }

  func testExecute_success() throws {
    try useCase()

    XCTAssertTrue(lockWalletRepositorySpy.unlockWalletCalled)
  }

  func testExecute_repositoryThrowsError_throwsError() throws {
    lockWalletRepositorySpy.unlockWalletThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var lockWalletRepositorySpy: LockWalletRepositoryProtocolSpy!
  private var useCase: UnlockWalletUseCase!

  // swiftlint:enable all

  private func registerMocks() {
    lockWalletRepositorySpy = LockWalletRepositoryProtocolSpy()
    Container.shared.lockWalletRepository.register { self.lockWalletRepositorySpy }
  }

}
