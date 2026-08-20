import BITCore
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth

final class GetLoginAttemptCounterUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    repository = LoginRepositoryProtocolSpy()

    Container.shared.loginRepository.register { self.repository }

    useCase = GetLoginAttemptCounterUseCase()
  }

  func testHappyPath_biometric() throws {
    let biometricAttempt = 1
    repository.getAttemptsKindReturnValue = biometricAttempt

    let result = try useCase(kind: .biometric)

    XCTAssertTrue(repository.getAttemptsKindCalled)
    XCTAssertEqual(repository.getAttemptsKindCallsCount, 1)
    XCTAssertEqual(repository.getAttemptsKindReceivedKind, .biometric)
    XCTAssertEqual(result, biometricAttempt)
  }

  func testHappyPath_pin() throws {
    let pinAttempt = 1
    repository.getAttemptsKindReturnValue = pinAttempt

    let result = try useCase(kind: .appPin)

    XCTAssertTrue(repository.getAttemptsKindCalled)
    XCTAssertEqual(repository.getAttemptsKindCallsCount, 1)
    XCTAssertEqual(repository.getAttemptsKindReceivedKind, .appPin)
    XCTAssertEqual(result, pinAttempt)
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: GetLoginAttemptCounterUseCase!
  private var repository: LoginRepositoryProtocolSpy!
  // swiftlint:enable all

}
