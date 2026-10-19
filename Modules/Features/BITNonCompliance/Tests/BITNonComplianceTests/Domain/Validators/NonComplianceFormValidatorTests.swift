import Factory
import Testing
@testable import BITNonCompliance

struct NonComplianceFormValidatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.descriptionFormFieldMinimumLength.register { @MainActor in Self.minimumDescriptionLengthMock }
    Container.shared.descriptionFormFieldMaximumLength.register { @MainActor in Self.maximumDescriptionLengthMock }
  }

  // MARK: Internal

  @Test
  func validate_emptyEmail_returnsValid() {
    let result = validator.validate("", for: .email)
    #expect(result == .valid)
  }

  @Test
  func validate_validEmail_returnsValid() {
    for email in validEmails {
      let result = validator.validate(email, for: .email)
      #expect(result == .valid, "Expected \(email) to be valid")
    }
  }

  @Test
  func validate_invalidEmail_returnsMalformed() {
    for email in invalidEmails {
      let result = validator.validate(email, for: .email)
      #expect(result == .malformed, "Expected \(email) to be malformed")
    }
  }

  @Test
  func validate_validDescription_returnsValid() {
    for length in Self.minimumDescriptionLengthMock...Self.maximumDescriptionLengthMock {
      let description = String(repeating: "x", count: length)

      let result = validator.validate(description, for: .description)

      #expect(result == .valid, "Invalid state for length: \(length)")
    }
  }

  @Test
  func validate_tooShortDescription_returnsTooShort() {
    for length in 0...Self.minimumDescriptionLengthMock - 1 {
      let description = String(repeating: "x", count: length)

      let result = validator.validate(description, for: .description)

      #expect(result == .tooShort, "Invalid state for length: \(length)")
    }
  }

  @Test
  func validate_tooLongDescription_returnsTooShort() {
    let description = String(repeating: "x", count: Self.maximumDescriptionLengthMock + 1)

    let result = validator.validate(description, for: .description)

    #expect(result == .tooLong)
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
