import BITJsonCanonicalizer
import CryptoKit
import Factory
import Spyable
import XCTest
@testable import BITOca

// MARK: - OcaCESRHashValidatorTests

// swiftlint:disable all

final class CESRHashValidatorIntegrationTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    validator = OcaCESRHashValidator()
  }

  func testValidator_validOCABundleInputs_returnsTrue() throws {
    for oca in OCACaptureBaseMocks.validInputs {
      let data = try XCTUnwrap(oca.data(using: .utf8))
      XCTAssertTrue(validator.validate(data: data))
    }
  }

  func testValidator_invalidDigest_returnsFalse() throws {
    let data = try XCTUnwrap(OCACaptureBaseMocks.wrongDigest.data(using: .utf8))
    XCTAssertFalse(validator.validate(data: data))
  }

  // MARK: Private

  private var validator: OcaCESRHashValidatorProtocol!

}

// swiftlint:enable all
