import Foundation
import Testing
@testable import BITCrypto

struct SRIValidatorTests {

  // MARK: Internal

  @Test
  func validate_success() throws {
    let integrity = "sha384-OLBgp1GsljhM2TJ+sbHjaiH9txEUvgdDTAzHv2P24donTt6/529l+9Ua0vFImLlb"

    let result = try sriValidator.validate(mockData, with: integrity)

    #expect(result)
  }

  @Test
  func validate_failure() throws {
    let integrity = "sha384-XXX"

    let result = try sriValidator.validate(mockData, with: integrity)

    #expect(!result)
  }

  @Test
  func validate_failure_throwsMalformedIntegriy() throws {
    let integrity = "incorrect integrity"

    #expect(throws: SRIError.malformedIntegrity) {
      try sriValidator.validate(mockData, with: integrity)
    }
  }

  func testValidate_failure_throwsUnsupportedAlgorithm() throws {
    let integrity = "sha224-H8BRh8j48O9oYatfu5AZzq6A9RINhZO5H16dQZngK7T62em8MUt1FLm52t+eX6xO"

    #expect(throws: SRIError.unsupportedAlgorithm) {
      try sriValidator.validate(mockData, with: integrity)
    }
  }

  // MARK: Private

  private var sriValidator = SRIValidator()
  private let mockData = Data()
}
