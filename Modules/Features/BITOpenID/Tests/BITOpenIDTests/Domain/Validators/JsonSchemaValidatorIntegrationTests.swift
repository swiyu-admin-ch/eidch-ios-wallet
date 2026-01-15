import JsonSchemaValidator
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

final class JsonSchemaValidatorIntegrationTests: XCTestCase {

  // MARK: Internal

  // swiftlint:disable force_unwrapping

  func testValidateJsonObject_validArguments_success() throws {
    XCTAssertTrue(try JsonSchemaValidator().validate(jsonObject: credential, with: schemaCredential))
  }

  func testValidateDictionary_validArguments_success() throws {
    let jsonDict = try? JSONSerialization.jsonObject(with: credential) as? [String: Any]
    XCTAssertTrue(try JsonSchemaValidator().validate(dictionary: jsonDict!, with: schemaCredential))
  }

  func testValidateDictionary_requiredArgumentsOnlySet_success() throws {
    let jsonDict = try? JSONSerialization.jsonObject(with: credentialRequiredSetOnly) as? [String: Any]
    XCTAssertTrue(try JsonSchemaValidator().validate(dictionary: jsonDict!, with: schemaCredential))
  }

  func testValidate_schemaMalformed_throwsError() throws {
    XCTAssertThrowsError(try JsonSchemaValidator().validate(jsonObject: credential, with: schemaMalformed)) { error in
      guard case ValidatorError.InvalidSchema(_) = error else {
        return XCTFail("Expected InvalidSchema, got \(error)")
      }
    }
  }

  func testValidateJsonObject_credentialMissingClaim_failure() throws {
    XCTAssertFalse(try JsonSchemaValidator().validate(jsonObject: credentialMissingClaim, with: schemaCredential))
  }

  func testValidateDictionary_credentialMissingClaim_failure() throws {
    let jsonDict = try? JSONSerialization.jsonObject(with: credentialMissingClaim) as? [String: Any]
    XCTAssertFalse(try JsonSchemaValidator().validate(dictionary: jsonDict!, with: schemaCredential))
  }

  // MARK: Private

  private let schemaCredential = Mocker.getData(fromFile: "json-schema-credential", ofType: "json", bundle: Bundle.module)!
  private let jsonMetaSchema202012 = Mocker.getData(fromFile: "json-meta-schema-202012", ofType: "json", bundle: Bundle.module)!
  private let credential = Mocker.getData(fromFile: "credential-valid-json", ofType: "json", bundle: Bundle.module)!
  private let credentialRequiredSetOnly = Mocker.getData(fromFile: "credential-required-set-only-json", ofType: "json", bundle: Bundle.module)!
  private let schemaMalformed = Mocker.getData(fromFile: "json-schema-malformed", ofType: "json", bundle: Bundle.module)!
  private let credentialMissingClaim = Mocker.getData(fromFile: "credential-missing-required-claim", ofType: "json", bundle: Bundle.module)!
  // swiftlint:enable force_unwrapping
}
