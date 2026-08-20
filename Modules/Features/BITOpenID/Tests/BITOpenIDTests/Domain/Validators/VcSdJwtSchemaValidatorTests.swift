import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITOpenID

// MARK: - VcSdJwtSchemaValidatorTests

@Suite(.container)
struct VcSdJwtSchemaValidatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.jsonSchemaValidator.register { [jsonSchemaValidatorSpy] in jsonSchemaValidatorSpy }
    jsonSchemaValidatorSpy.validateJsonWithReturnValue = true
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = true

    validator = VcSdJwtSchemaValidator()
  }

  // MARK: Internal

  @Test
  func validate_argumentsPassed() throws {
    _ = try validator.validate(schema: schemaCredential)

    #expect(jsonSchemaValidatorSpy.validateJsonObjectWithReceivedInvocations.count == 2, "Expected two schema validations to be performed")
  }

  @Test
  func validate_schemaValidationPasses_returnsTrue() throws {
    #expect(try validator.validate(schema: schemaCredential))
  }

  @Test
  func validate_schemaConformanceFails_returnsFalse() throws {
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = false

    #expect(try !validator.validate(schema: schemaCredential))
  }

  @Test
  func validate_schemaValidationSucceeds_returnsTrue() throws {
    jsonSchemaValidatorSpy.validateJsonObjectWithReturnValue = true

    #expect(try validator.validate(schema: schemaCredential))
  }

  @Test
  func validate_schemaWithRegex_rejectedBeforeValidation() throws {
    #expect(try !validator.validate(schema: schemaWithRegex))
    #expect(jsonSchemaValidatorSpy.validateJsonObjectWithReceivedInvocations.isEmpty, "Schemas using regular expressions must be rejected before any validation runs")
  }

  // MARK: Private

  private let validator: VcSdJwtSchemaValidator

  private let schemaCredential = String.Mock.schemaCredential
  private let schemaWithRegex = String.Mock.schemaWithRegex

  private let jsonSchemaValidatorSpy = JsonSchemaValidatorProtocolSpy()
}
