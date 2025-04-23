import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class ValidateRequestObjectUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }

    useCase = ValidateRequestObjectUseCase()

    jwsSignatureValidatorMock.validateJwsDidReturnValue = true
  }

  // MARK: - JSON Request Object

  func testValidationSuccess() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sample

    let result = await useCase.execute(mockRequestObject)

    XCTAssertTrue(result)
  }

  func testValidationWithUnsupportedResponseType() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.unsupportedResponseTypeSample

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithUnsupportedResponseMode() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.unsupportedResponseModeSample

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithUnsupportedClientIdScheme() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithUnsupportedClientIdScheme

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithClientIdButNoClientIdScheme() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithClientIdAndWithoutClientIdScheme

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithUnsupportedClientId() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithUnsupportedClientId

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithoutAnyConstraintsFields() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithoutAnyConstraintsFields

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithInvalidConstraintsPath() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithInvalidContraintPath

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationWithInvalidConstraintsPathRegex() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sampleWithInvalidContraintPath

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  // MARK: - JWT Request Object

  func testValidationJwtRequestObjectSuccess() async {
    let result = await useCase.execute(jwtRequestObjectMock)

    XCTAssertTrue(result)
  }

  func testValidationJwtRequestObjectSuccess_argumentsPassed() async {
    let mockRequestObject = RequestObject.Mock.VcSdJwt.sample

    _ = await useCase.execute(jwtRequestObjectMock)

    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedJws as? JWS, jwtRequestObjectMock.jws)
    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedDid, mockRequestObject.clientId)
  }

  func testValidationJwtRequestObjectWrongAlgorithm() async {
    let mockRequestObject = JWTRequestObject.Mock.unsupportedAlgorithm

    let result = await useCase.execute(mockRequestObject)

    XCTAssertFalse(result)
  }

  func testValidationJwtRequestObjectFailure() async {
    jwsSignatureValidatorMock.validateJwsDidThrowableError = TestingError.error

    let result = await useCase.execute(jwtRequestObjectMock)

    XCTAssertFalse(result)
  }

  func testValidationJwtRequestObjectInvalidSignature() async {
    jwsSignatureValidatorMock.validateJwsDidReturnValue = false

    let result = await useCase.execute(jwtRequestObjectMock)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private static let jwsHeader = JWSHeader(algorithm: JWTAlgorithm.ES256)

  private var jwsSignatureValidatorMock = JWSSignatureValidatorMock()
  private var useCase = ValidateRequestObjectUseCase()

  private var jwtRequestObjectMock: JWTRequestObject = .Mock.sample

}
