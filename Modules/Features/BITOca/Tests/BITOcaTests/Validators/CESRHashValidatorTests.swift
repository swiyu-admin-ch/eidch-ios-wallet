import BITJsonCanonicalizer
import CryptoKit
import Factory
import Spyable
import XCTest
@testable import BITOca
@testable import BITTestingCore

// swiftlint:disable all

// MARK: - CESRHashValidatorTests

final class CESRHashValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    mockJsonCanonicalizer = JsonCanonicalizerProtocolSpy()
    Container.shared.jsonCanonicalizer.register { self.mockJsonCanonicalizer }
    validator = OcaCESRHashValidator()

    setupSuccessState()
  }

  override func tearDown() {
    mockJsonCanonicalizer = nil
    validator = nil
    Container.shared.reset()
    super.tearDown()
  }

  func testValidate_withValidOCAJson_CallCount() {
    _ = validator.validate(jsonString: OCACaptureBaseMocks.validInput01)

    XCTAssertEqual(mockJsonCanonicalizer.canonicalizeJsonStringCallsCount, 1)
  }

  func testValidate_withValidOCAJson_shouldReturnTrue() {
    XCTAssertTrue(validator.validate(jsonString: OCACaptureBaseMocks.validInput01))
  }

  func testValidate_withMissmatchOCACanonicalizedJson_returnsFalse() {
    let data = Data(OCACaptureBaseMocks.validInput02DummyCanonicalized.utf8)
    mockJsonCanonicalizer.canonicalizeJsonStringReturnValue = data

    XCTAssertFalse(validator.validate(jsonString: OCACaptureBaseMocks.validInput01))
  }

  func testValidate_errorOnJsonCanonicalizer_returnsFalse() {
    mockJsonCanonicalizer.canonicalizeJsonStringThrowableError = TestingError.error

    XCTAssertFalse(validator.validate(jsonString: OCACaptureBaseMocks.validInput01))
  }

  func testValidator_missingDigest_returnsFalse() throws {
    let data = try XCTUnwrap(OCACaptureBaseMocks.noDigest.data(using: .utf8))
    XCTAssertFalse(validator.validate(data: data))
  }

  func testValidator_emptyDigest_returnsFalse() throws {
    let data = try XCTUnwrap(OCACaptureBaseMocks.emptyDigest.data(using: .utf8))
    XCTAssertFalse(validator.validate(data: data))
  }

  func testValidator_wrongJson_returnsFalse() throws {
    let data = try XCTUnwrap(OCACaptureBaseMocks.wrongJson.data(using: .utf8))
    XCTAssertFalse(validator.validate(data: data))
  }

  func testValidator_emptyString_returnsFalse() {
    XCTAssertFalse(validator.validate(jsonString: ""))
  }

  // MARK: Private

  private var mockJsonCanonicalizer: JsonCanonicalizerProtocolSpy!
  private var validator: OcaCESRHashValidator!

  private func setupSuccessState() {
    let data = Data(OCACaptureBaseMocks.validInput01DummyCanonicalized.utf8)
    mockJsonCanonicalizer.canonicalizeJsonStringReturnValue = data
  }

}

// swiftlint:enable all
