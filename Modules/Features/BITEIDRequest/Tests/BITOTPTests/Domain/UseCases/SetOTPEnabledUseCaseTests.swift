import Factory
import XCTest
@testable import BITOTP

// swiftlint: disable implicitly_unwrapped_optional

final class SetOTPEnabledUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    repository = OTPEnabledRepositoryProtocolSpy()

    Container.shared.otpEnabledRepository.register { self.repository }
  }

  func testCallAsFunction_setsRepositoryValue() {
    let useCase = SetOTPEnabledUseCase()

    useCase(false)

    XCTAssertEqual(repository.setReceivedInvocations, [false])
  }

  // MARK: Private

  private var repository: OTPEnabledRepositoryProtocolSpy!
}

// swiftlint: enable implicitly_unwrapped_optional
