import BITCore
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth

final class ResetLoginAttemptCounterUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    repository = LoginRepositoryProtocolSpy()

    Container.shared.loginRepository.register { self.repository }

    useCase = ResetLoginAttemptCounterUseCase()
  }

  func testHappyPath() throws {
    repository.resetAttemptsKindClosure = { _ in }

    try useCase()

    XCTAssertTrue(repository.resetAttemptsKindCalled)
    XCTAssertEqual(repository.resetAttemptsKindCallsCount, 2)
    XCTAssertEqual(repository.resetAttemptsKindReceivedInvocations, [.appPin, .biometric])
  }

  func testResetBiometric() throws {
    repository.resetAttemptsKindClosure = { _ in }

    try useCase(kind: .biometric)

    XCTAssertTrue(repository.resetAttemptsKindCalled)
    XCTAssertEqual(repository.resetAttemptsKindCallsCount, 1)
    XCTAssertEqual(repository.resetAttemptsKindReceivedKind, .biometric)
  }

  func testResetPin() throws {
    repository.resetAttemptsKindClosure = { _ in }

    try useCase(kind: .appPin)

    XCTAssertTrue(repository.resetAttemptsKindCalled)
    XCTAssertEqual(repository.resetAttemptsKindCallsCount, 1)
    XCTAssertEqual(repository.resetAttemptsKindReceivedKind, .appPin)
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: ResetLoginAttemptCounterUseCase!
  private var repository: LoginRepositoryProtocolSpy!
  // swiftlint:enable all

}
