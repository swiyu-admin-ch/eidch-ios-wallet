import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore

// MARK: - LockWalletUseCaseTests

final class LockWalletUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    useCase = LockWalletUseCase()
  }

  func testExecute_success() throws {
    try useCase()

    XCTAssertTrue(lockWalletRepositorySpy.lockWalletCalled)
  }

  func testExecute_repositoryThrowsError_throwsError() throws {
    lockWalletRepositorySpy.lockWalletThrowableError = TestingError.error

    XCTAssertThrowsError(try useCase()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var lockWalletRepositorySpy: LockWalletRepositoryProtocolSpy!
  private var useCase: LockWalletUseCase!

  // swiftlint:enable all

  private func registerMocks() {
    lockWalletRepositorySpy = LockWalletRepositoryProtocolSpy()
    Container.shared.lockWalletRepository.register { self.lockWalletRepositorySpy }
  }

}
