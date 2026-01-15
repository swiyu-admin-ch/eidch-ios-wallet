import Foundation
import JsonSchemaValidator
import XCTest
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

final class VcSdJwtSchemaValidatorIntegrationTests: XCTestCase {

  // MARK: Internal

  func testValidate_success() throws {
    XCTAssertTrue(try validator.validate(schema: schemaCredential))
  }

  func testValidate_emptySchema_throwsError() throws {
    XCTAssertThrowsError(try validator.validate(schema: Data()))
  }

  func testValidate_invalidSchema_returnsFalse() throws {
    XCTAssertFalse(try validator.validate(schema: schemaMalformed))
  }

  func testValidate_schemaMissingVcSdJwtSupport_returnsFalse() throws {
    // schema only passes meta-schema, but not vcSdJwt-specific validation
    XCTAssertFalse(try validator.validate(schema: schemaInsufficient))
  }

  // MARK: Private

  private let validator = VcSdJwtSchemaValidator()

  private let schemaCredential = String.Mock.schemaCredential
  private let schemaMalformed = String.Mock.schemaMalformed
  private let schemaInsufficient = String.Mock.schemaInsufficient
}
