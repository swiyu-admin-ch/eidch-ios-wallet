import Factory
import Foundation
import JsonSchemaValidatorSources
import XCTest
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
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
    let _ = try validator.validate(claims, schema: schemaCredential)

    XCTAssertEqual(jsonSchemaValidatorSpy.validateDictionaryWithReceivedArguments?.dictionary.keys.count, 2)
    XCTAssertTrue(jsonSchemaValidatorSpy.validateDictionaryWithReceivedArguments?.dictionary["iss"] as? String == "test")
    XCTAssertTrue(jsonSchemaValidatorSpy.validateDictionaryWithReceivedArguments?.dictionary["vct"] as? String == "test")
    XCTAssertEqual(jsonSchemaValidatorSpy.validateDictionaryWithReceivedArguments?.jsonSchema, schemaCredential)
    XCTAssertEqual(jsonSchemaValidatorSpy.validateJsonObjectWithReceivedInvocations.count, 2, "Expected two schema validations to be performed")
  }

  func testValidate_schemaValidationPasses_returnsTrue() throws {
    XCTAssertTrue(try validator.validate(claims, schema: schemaCredential))
    XCTAssertTrue(jsonSchemaValidatorSpy.validateDictionaryWithCalled)
  }

  func testValidate_schemaConformanceFails_returnsFalse() throws {
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = false
    jsonSchemaValidatorSpy.validateDictionaryWithReturnValue = true

    XCTAssertFalse(try validator.validate(claims, schema: schemaCredential))
  }

  func testValidate_schemaValidationFails_returnsFalse() throws {
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = true
    jsonSchemaValidatorSpy.validateDictionaryWithReturnValue = false

    XCTAssertFalse(try validator.validate(claims, schema: schemaCredential))
  }

  // MARK: Private

  private var validator = VcSdJwtSchemaValidator()

  private let claims = VcSdJwtPayload(issuer: "test", vct: "test").asDictionary()
  private let schemaCredential = String.Mock.schemaCredential

  private var jsonSchemaValidatorSpy = JsonSchemaValidatorProtocolSpy()

  private func registerMocks() {
    jsonSchemaValidatorSpy = JsonSchemaValidatorProtocolSpy()

    Container.shared.jsonSchemaValidator.register { self.jsonSchemaValidatorSpy }
  }

  private func success() {
    jsonSchemaValidatorSpy.validateDictionaryWithReturnValue = true
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = true
  }
}
