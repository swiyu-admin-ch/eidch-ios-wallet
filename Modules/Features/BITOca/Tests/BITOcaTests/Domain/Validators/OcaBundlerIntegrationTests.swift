import Factory
import Spyable
import XCTest
@testable import BITCore
@testable import BITOca

// MARK: - OcaBundleValidatorTests

final class OcaBundlerIntegrationTests: XCTestCase {

  func testCreateOcaBundle_validSimple_createsValid() throws {
    let ocaBundle = try OcaBundler().createOcaBundle(OcaBundle.Mock.simpleSampleData)
    XCTAssertEqual(ocaBundle.captureBases.count, 1)
    XCTAssertEqual(ocaBundle.overlays.count, 13)
  }

  func testCreateOcaBundle_validElfa_createsValid() throws {
    let ocaBundle = try OcaBundler().createOcaBundle(OcaBundle.Mock.elfaData)
    XCTAssertEqual(ocaBundle.captureBases.count, 2)
    XCTAssertEqual(ocaBundle.overlays.count, 26)
  }

  func testCreateOcaBundle_nested_createsValid() throws {
    let ocaBundle = try OcaBundler().createOcaBundle(OcaBundle.Mock.nestedData)
    XCTAssertEqual(ocaBundle.captureBases.count, 4)
    XCTAssertEqual(ocaBundle.overlays.count, 20)
  }
}
