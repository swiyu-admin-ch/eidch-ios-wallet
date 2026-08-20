import BITCore
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth

// swiftlint:disable all
final class ValidatePinCodeRuleUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    useCase = ValidatePinCodeRuleUseCase()
  }

  func testHappyPath() throws {
    let pinCode = "12345678"
    XCTAssertNoThrow(try useCase(pinCode))
  }

  func testEmptyPinCode() throws {
    let pinCode = ""
    XCTAssertThrowsError(try useCase(pinCode)) { error in
      XCTAssertEqual(error as! PinCodeError, .empty)
    }
  }

  func testEmptyPinCodeWithSpaces() throws {
    let pinCode = "         "
    XCTAssertThrowsError(try useCase(pinCode)) { error in
      XCTAssertEqual(error as! PinCodeError, .empty)
    }
  }

  func testValidRawSizePinCodeWithTrimmableSpaces() throws {
    let pinCode = " 12345 "
    XCTAssertThrowsError(try useCase(pinCode)) { error in
      XCTAssertEqual(error as! PinCodeError, .tooShort)
    }
  }

  func testShortPinCode() throws {
    let pinCode = "1234"
    XCTAssertThrowsError(try useCase(pinCode)) { error in
      XCTAssertEqual(error as! PinCodeError, .tooShort)
    }
  }

  func testVeryLongPinCode() throws {
    let pinCode = "123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789"
    XCTAssertNoThrow(try useCase(pinCode))
  }

  // MARK: Private

  private var useCase: ValidatePinCodeRuleUseCaseProtocol!
}

// swiftlint:enable all
