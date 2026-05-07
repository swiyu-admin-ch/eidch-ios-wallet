import Factory
import Spyable
import XCTest
@testable import BITOTP

// swiftlint: disable implicitly_unwrapped_optional

final class RequestOTPUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    repository = OTPRequestRepositoryProtocolSpy()

    Container.shared.otpRequestRepository.register { self.repository }
  }

  func testCallAsFunction_success_requestsMail() async throws {
    let useCase = RequestOTPUseCase()

    try await useCase(email: "mail@example.admin.ch")

    XCTAssertEqual(repository.requestOTPEmailReceivedInvocations, ["mail@example.admin.ch"])
  }

  func testCallAsFunction_failure_throwsError() async {
    repository.requestOTPEmailThrowableError = OTPError.forbiddenEmail
    let useCase = RequestOTPUseCase()

    do {
      try await useCase(email: "mail@example.admin.ch")
      XCTFail("Expected error")
    } catch {
      XCTAssertNotNil(error)
    }
  }

  // MARK: Private

  private var repository: OTPRequestRepositoryProtocolSpy!
}

// swiftlint: enable implicitly_unwrapped_optional
