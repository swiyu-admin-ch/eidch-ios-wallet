import Foundation
import JsonSchemaValidatorSources
import XCTest
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

final class VcSdJwtSchemaValidatorIntegrationTests: XCTestCase {

  // MARK: Internal

  func testValidate_success() throws {
    let claims = vcSdJwtMock.getClaimsDictionary(.all)
    XCTAssertTrue(try validator.validate(claims, schema: schemaCredential))
  }

  func testValidate_emptySchema_throwsError() throws {
    let claims = vcSdJwtMock.getClaimsDictionary(.all)
    XCTAssertThrowsError(try validator.validate(claims, schema: Data()))
  }

  func testValidate_invalidSchema_returnsFalse() throws {
    let claims = vcSdJwtMock.getClaimsDictionary(.all)
    XCTAssertFalse(try validator.validate(claims, schema: schemaMalformed))
  }

  func testValidate_invalidClaims_returnsFalse() throws {
    let claims: [String: Any] = [:]
    XCTAssertFalse(try validator.validate(claims, schema: schemaCredential))
    let insufficientClaims: [String: Any] = ["vct": "test"]
    XCTAssertFalse(try validator.validate(insufficientClaims, schema: schemaCredential))
  }

  func testValidate_schemaMissingVcSdJwtSupport_returnsFalse() throws {
    let claims = vcSdJwtMock.getClaimsDictionary(.all)
    // schema only passes meta-schema, but not vcSdJwt-specific validation
    XCTAssertFalse(try validator.validate(claims, schema: schemaInsufficient))
  }

  // MARK: Private

  private let validator = VcSdJwtSchemaValidator()

  private let vcSdJwtMock = VcSdJwtPayload.Mock.sample
  private let schemaCredential = String.Mock.schemaCredential
  private let schemaMalformed = String.Mock.schemaMalformed
  private let schemaInsufficient = String.Mock.schemaInsufficient
}
