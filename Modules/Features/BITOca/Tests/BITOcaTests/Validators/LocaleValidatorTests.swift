import XCTest
@testable import BITOca

// MARK: - LocaleValidatorTests

final class LocaleValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    validator = LocaleValidator()
  }

  func testValidate_languageOnly_returnsTrue() throws {
    XCTAssertTrue(validator.validate("en"))
    XCTAssertTrue(validator.validate("xy"))
  }

  func testValidate_languageAndRegion_returnsTrue() throws {
    XCTAssertTrue(validator.validate("en-US"))
    XCTAssertTrue(validator.validate("en-XY"))
    XCTAssertTrue(validator.validate("xy-XY"))
  }

  func testValidate_emptyString_returnsFalse() throws {
    XCTAssertFalse(validator.validate(""))
  }

  func testValidate_invalidFormat_returnsFalse() throws {
    XCTAssertFalse(validator.validate("x"))
    XCTAssertFalse(validator.validate("è"))
    XCTAssertFalse(validator.validate("en-"))
    XCTAssertFalse(validator.validate("EN"))
    XCTAssertFalse(validator.validate("en-xy"))
    XCTAssertFalse(validator.validate("abcd"))
    XCTAssertFalse(validator.validate("en-xyz"))
    XCTAssertFalse(validator.validate("en-ÜÄ"))
  }

  // MARK: Private

  private var validator = LocaleValidator()
}
