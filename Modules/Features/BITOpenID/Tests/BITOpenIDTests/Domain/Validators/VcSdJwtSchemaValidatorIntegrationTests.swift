import Foundation
import Testing
@testable import BITOpenID

// MARK: - VcSdJwtSchemaValidatorIntegrationTests

struct VcSdJwtSchemaValidatorIntegrationTests {

  // MARK: Internal

  @Test
  func validate_success() throws {
    #expect(try validator.validate(schema: schemaCredential))
  }

  @Test
  func validate_emptySchema_throwsError() throws {
    #expect(throws: (any Error).self) {
      try validator.validate(schema: Data())
    }
  }

  @Test
  func validate_invalidSchema_returnsFalse() throws {
    #expect(try !validator.validate(schema: schemaMalformed))
  }

  @Test
  func validate_schemaMissingVcSdJwtSupport_returnsFalse() throws {
    // schema only passes meta-schema, but not vcSdJwt-specific validation
    #expect(try !validator.validate(schema: schemaInsufficient))
  }

  @Test
  func validate_schemaWithRegex_returnsFalse() throws {
    #expect(try !validator.validate(schema: schemaWithRegex))
  }

  // MARK: Private

  private let validator = VcSdJwtSchemaValidator()

  private let schemaCredential = String.Mock.schemaCredential
  private let schemaMalformed = String.Mock.schemaMalformed
  private let schemaInsufficient = String.Mock.schemaInsufficient
  private let schemaWithRegex = String.Mock.schemaWithRegex
}
