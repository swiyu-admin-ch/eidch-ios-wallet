// swiftlint:disable implicitly_unwrapped_optional
import XCTest
@testable import BITCrypto

final class SRIValidatorTests: XCTest {

  // MARK: Internal

  override func setUp() {
    sriValidator = SRIValidator()
  }

  func testValidate_success() throws {
    let integrity = "sha384-H8BRh8j48O9oYatfu5AZzq6A9RINhZO5H16dQZngK7T62em8MUt1FLm52t+eX6xO"

    let result = try sriValidator.validate(mockData, with: integrity)

    XCTAssertTrue(result)
  }

  func testValidate_failure() throws {
    let integrity = "sha384-XXX"

    let result = try sriValidator.validate(mockData, with: integrity)

    XCTAssertFalse(result)
  }

  func testValidate_failure_throwsMalformedIntegriy() throws {
    let integrity = "incorrect integrity"

    XCTAssertThrowsError(try sriValidator.validate(mockData, with: integrity)) { error in
      XCTAssertEqual(error as? SRIError, .malformedIntegrity)
    }
  }

  func testValidate_failure_throwsUnsupportedAlgorithm() throws {
    let integrity = "sha224-H8BRh8j48O9oYatfu5AZzq6A9RINhZO5H16dQZngK7T62em8MUt1FLm52t+eX6xO"

    XCTAssertThrowsError(try sriValidator.validate(mockData, with: integrity)) { error in
      XCTAssertEqual(error as? SRIError, .unsupportedAlgorithm)
    }
  }

  // MARK: Private

  private var sriValidator: SRIValidatorProtocol!
  private let mockData = Data()
}

// swiftlint:enable implicitly_unwrapped_optional
