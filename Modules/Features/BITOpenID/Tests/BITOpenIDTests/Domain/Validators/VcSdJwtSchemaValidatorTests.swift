import Factory
import Foundation
import JsonSchemaValidator
import XCTest
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

final class VcSdJwtSchemaValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    validator = VcSdJwtSchemaValidator()
    success()
  }

  func testValidate_argumentsPassed() throws {
    _ = try validator.validate(schema: schemaCredential)

    XCTAssertEqual(jsonSchemaValidatorSpy.validateJsonObjectWithReceivedInvocations.count, 2, "Expected two schema validations to be performed")
  }

  func testValidate_schemaValidationPasses_returnsTrue() throws {
    XCTAssertTrue(try validator.validate(schema: schemaCredential))
  }

  func testValidate_schemaConformanceFails_returnsFalse() throws {
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = false

    XCTAssertFalse(try validator.validate(schema: schemaCredential))
  }

  func testValidate_schemaValidationFails_returnsFalse() throws {
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = true

    XCTAssertTrue(try validator.validate(schema: schemaCredential))
  }

  // MARK: Private

  private var validator = VcSdJwtSchemaValidator()

  private let schemaCredential = String.Mock.schemaCredential

  private var jsonSchemaValidatorSpy = JsonSchemaValidatorProtocolSpy()

  private func registerMocks() {
    jsonSchemaValidatorSpy = JsonSchemaValidatorProtocolSpy()

    Container.shared.jsonSchemaValidator.register { self.jsonSchemaValidatorSpy }
  }

  private func success() {
    jsonSchemaValidatorSpy.validateJsonWithReturnValue = true
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = true
  }
}
