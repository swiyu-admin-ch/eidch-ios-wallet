// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITNonCompliance

@MainActor
final class NonComplianceFormValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.descriptionFormFieldMinimumLength.register { @MainActor in Self.minimumDescriptionLengthMock }
    Container.shared.descriptionFormFieldMaximumLength.register { @MainActor in Self.maximumDescriptionLengthMock }
    validator = NonComplianceFormValidator()
  }

  func testValidate_emptyEmail_returnsValid() {
    let result = validator.validate("", for: .email)
    XCTAssertEqual(result, .valid)
  }

  func testValidate_validEmail_returnsValid() {
    for email in validEmails {
      let result = validator.validate(email, for: .email)
      XCTAssertEqual(result, .valid, "Expected \(email) to be valid")
    }
  }

  func testValidate_invalidEmail_returnsMalformed() {
    for email in invalidEmails {
      let result = validator.validate(email, for: .email)
      XCTAssertEqual(result, .malformed, "Expected \(email) to be malformed")
    }
  }

  func testValidate_validDescription_returnsValid() {
    for length in Self.minimumDescriptionLengthMock...Self.maximumDescriptionLengthMock {
      let description = String(repeating: "x", count: length)

      let result = validator.validate(description, for: .description)

      XCTAssertEqual(result, .valid, "Invalid state for length: \(length)")
    }
  }

  func testValidate_tooShortDescription_returnsTooShort() {
    for length in 0...Self.minimumDescriptionLengthMock - 1 {
      let description = String(repeating: "x", count: length)

      let result = validator.validate(description, for: .description)

      XCTAssertEqual(result, .tooShort, "Invalid state for length: \(length)")
    }
  }

  func testValidate_tooLongDescription_returnsTooShort() {
    let description = String(repeating: "x", count: Self.maximumDescriptionLengthMock + 1)

    let result = validator.validate(description, for: .description)

    XCTAssertEqual(result, .tooLong)
  }

  // MARK: Private

  private static let minimumDescriptionLengthMock = 5
  private static let maximumDescriptionLengthMock = 10

  private var validator = NonComplianceFormValidator()

  private let validEmails = [
    "abc@def.com",
    "a@b.io",
    "user.name@example.org",
    "user_name123@example.org",
    "user+alias@example.org",
    "user.name@sub.domain.example.org",
    "USER@EXAMPLE.ORG",
  ]

  private let invalidEmails = [
    "justText",
    "@example.org",
    "user@.org",
    "user@example",
    "user@@example.com",
    "user@example.c",
    "user name@example.org",
    "user@example,org",
  ]
}
