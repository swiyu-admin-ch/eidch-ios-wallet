import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class RequestObjectValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    validator = RequestObjectValidator()
  }

  // MARK: - JSON Request Object

  func testValidationSuccess() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sample

    let result = validator.validate(mockRequestObject)

    XCTAssertTrue(result)
  }

  func testValidationWithUnsupportedResponseType() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.unsupportedResponseTypeSample

    let result = validator.validate(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithUnsupportedClientIdScheme() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithUnsupportedClientIdScheme

    let result = validator.validate(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithClientIdButNoClientIdScheme() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithClientIdAndWithoutClientIdScheme

    let result = validator.validate(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithUnsupportedClientId() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithUnsupportedClientId

    let result = validator.validate(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithoutAnyConstraintsFields() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithoutAnyConstraintsFields

    let result = validator.validate(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithInvalidConstraintsPath() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithInvalidContraintPath

    let result = validator.validate(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithTransactionData() {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithTransactionData

    let result = validator.validate(mockRequestObject)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private var validator = RequestObjectValidator()

}
