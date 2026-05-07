import XCTest
@testable import BITOTP

final class OTPEnabledRepositoryTests: XCTestCase {

  func testGet_returnsStoredValue() {
    UserDefaults.standard.set(true, forKey: "otpEnabled")
    let repository = OTPEnabledRepository()

    let result = repository.get()

    XCTAssertTrue(result)
  }

  func testSet_persistsValue() {
    let repository = OTPEnabledRepository()

    repository.set(false)

    XCTAssertFalse(UserDefaults.standard.bool(forKey: "otpEnabled"))
  }
}
