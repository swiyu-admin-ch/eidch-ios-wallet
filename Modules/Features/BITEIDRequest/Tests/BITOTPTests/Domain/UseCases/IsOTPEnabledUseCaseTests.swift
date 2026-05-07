import Factory
import XCTest
@testable import BITOTP

// swiftlint: disable implicitly_unwrapped_optional

final class IsOTPEnabledUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    repository = OTPEnabledRepositoryProtocolSpy()

    Container.shared.otpEnabledRepository.register { self.repository }
  }

  func testCallAsFunction_returnsRepositoryValue() {
    repository.getReturnValue = true
    let useCase = IsOTPEnabledUseCase()

    let result = useCase()

    XCTAssertTrue(result)
    XCTAssertEqual(repository.getCallsCount, 1)
  }

  // MARK: Private

  private var repository: OTPEnabledRepositoryProtocolSpy!
}

// swiftlint: enable implicitly_unwrapped_optional
