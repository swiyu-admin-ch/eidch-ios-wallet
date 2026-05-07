import CryptoKit
import Factory
import Spyable
import XCTest
@testable import BITOca

// swiftlint:disable force_unwrapping

// MARK: - OcaCaptureBaseDigestsValidatorTests

final class OcaCaptureBaseDigestsValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    validator = OcaCaptureBaseDigestsValidator()
    successState()
  }

  func testValidate_valid_returnsTrue() {
    let data = OcaBundle.Mock.elfaData

    let result = validator.validate(data)

    XCTAssertTrue(result)
  }

  func testValidate_valid_argumentsPassed() {
    let captureBase1 = "{\"digest\":\"digest1\"}"
    let captureBase2 = "{\"digest\":\"digest2\"}"
    let data = "{\"capture_bases\":[\(captureBase1), \(captureBase2)]}".data(using: .utf8)!

    _ = validator.validate(data)

    XCTAssertEqual(cesrHashValidatorMock.validateDataCallsCount, 2)
    XCTAssertEqual(cesrHashValidatorMock.validateDataReceivedInvocations[0], captureBase1.data(using: .utf8))
    XCTAssertEqual(cesrHashValidatorMock.validateDataReceivedInvocations[1], captureBase2.data(using: .utf8))
  }

  func testValidate_emptyCaptureBases_returnsTrue() {
    let data = "{\"capture_bases\":[]}".data(using: .utf8)!

    let result = validator.validate(data)

    XCTAssertTrue(result)
  }

  func testValidate_noJson_returnsFalse() {
    let data = "not json".data(using: .utf8)!

    let result = validator.validate(data)

    XCTAssertFalse(result)
  }

  func testValidate_noCaptureBases_returnsFalse() {
    let data = "{\"overlays\":[]}".data(using: .utf8)!

    let result = validator.validate(data)

    XCTAssertFalse(result)
  }

  func testValidate_CESRReturnsFalseOne_returnsFalse() {
    let data = OcaBundle.Mock.elfaData
    cesrHashValidatorMock.validateDataReturnValue = false

    let result = validator.validate(data)

    XCTAssertFalse(result)
  }

  func testValidate_CESRReturnsFalseMulti_returnsFalse() {
    let data = "{\"capture_bases\":[{\"digest\":\"valid\"}, {\"digest\":\"invalid\"}]}".data(using: .utf8)!
    var count = 0
    cesrHashValidatorMock.validateDataClosure = { _ in
      if count == 0 {
        count += 1
        return true
      }
      return false
    }

    let result = validator.validate(data)

    XCTAssertFalse(result)
    XCTAssertEqual(cesrHashValidatorMock.validateDataCallsCount, 2)
  }

  // MARK: Private

  private var cesrHashValidatorMock = OcaCESRHashValidatorProtocolSpy()
  private var validator = OcaCaptureBaseDigestsValidator()

  private func registerMocks() {
    cesrHashValidatorMock = OcaCESRHashValidatorProtocolSpy()
    Container.shared.ocaCESRHashValidator.register { self.cesrHashValidatorMock }
  }

  private func successState() {
    cesrHashValidatorMock.validateDataReturnValue = true
  }
}

// swiftlint:enable all
