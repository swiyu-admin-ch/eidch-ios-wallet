import Factory
import Spyable
import XCTest
@testable import BITOTP

// swiftlint: disable implicitly_unwrapped_optional

final class VerifyOTPUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    repository = OTPRequestRepositoryProtocolSpy()

    Container.shared.otpRequestRepository.register { self.repository }
  }

  func testCallAsFunction_expiredOtp_throwsError() async {
    repository.verifyOTPEmailCodeThrowableError = OTPError.otpExpired
    let useCase = VerifyOTPUseCase()

    do {
      try await useCase(email: "mail@example.admin.ch", code: "123456")
      XCTFail("Expected error")
    } catch {
      XCTAssertTrue(true)
    }
  }

  func testCallAsFunction_tooManyRequests_throwsError() async {
    repository.verifyOTPEmailCodeThrowableError = OTPError.tooManyRequests
    let useCase = VerifyOTPUseCase()

    do {
      try await useCase(email: "mail@example.admin.ch", code: "123456")
      XCTFail("Expected error")
    } catch {
      XCTAssertTrue(true)
    }
  }

  func testCallAsFunction_otherError_throwsError() async {
    repository.verifyOTPEmailCodeThrowableError = OTPError.invalidClientAttestation
    let useCase = VerifyOTPUseCase()

    do {
      try await useCase(email: "mail@example.admin.ch", code: "123456")
      XCTFail("Expected error")
    } catch {
      XCTAssertTrue(true)
    }
  }

  // MARK: Private

  private var repository: OTPRequestRepositoryProtocolSpy!
}

// swiftlint: enable implicitly_unwrapped_optional
