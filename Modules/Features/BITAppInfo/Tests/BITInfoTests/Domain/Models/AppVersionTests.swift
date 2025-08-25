import Foundation
import XCTest
@testable import BITAppInfo

class AppVersionTests: XCTestCase {

  func test_rawValues() {
    let version = "1.0.0"
    let appVersion = AppVersion(version)

    XCTAssertEqual(appVersion.rawValue, version)
    XCTAssertEqual(appVersion.major, 1)
    XCTAssertEqual(appVersion.minor, 0)
    XCTAssertEqual(appVersion.patch, 0)
  }

  func testEquality() {
    let version1 = AppVersion("1.2.3")
    let version2 = AppVersion("1.2.3")
    XCTAssertEqual(version1, version2)

    let version3 = AppVersion("1.2.4")
    XCTAssertNotEqual(version1, version3)
  }

  func testInequalityDifferentMajor() {
    let version1 = AppVersion("1.2.3")
    let version2 = AppVersion("2.2.3")
    XCTAssertNotEqual(version1, version2)

    let version3 = AppVersion("1.2.3")
    XCTAssertEqual(version1, version3)
  }

  func testInequalityDifferentMinor() {
    let version1 = AppVersion("1.2.3")
    let version2 = AppVersion("1.3.3")
    XCTAssertNotEqual(version1, version2)

    let version3 = AppVersion("1.2.3")
    XCTAssertEqual(version1, version3)
  }

  func testInequalityDifferentPatch() {
    let version1 = AppVersion("1.2.3")
    let version2 = AppVersion("1.2.4")
    XCTAssertNotEqual(version1, version2)

    let version3 = AppVersion("1.2.3")
    XCTAssertEqual(version1, version3)
  }

  func testLessThanComparison() {
    XCTAssertTrue(AppVersion("0.1.1") < AppVersion("0.1.2"))
    XCTAssertTrue(AppVersion("0.0.1") < AppVersion("0.0.2"))
    XCTAssertTrue(AppVersion("1.2.3") < AppVersion("2.0.0"))
    XCTAssertTrue(AppVersion("1.2.3") < AppVersion("1.3.0"))
    XCTAssertTrue(AppVersion("1.2.3") < AppVersion("1.2.4"))

    XCTAssertFalse(AppVersion("2.0.0") < AppVersion("1.2.3"))
    XCTAssertFalse(AppVersion("1.3.0") < AppVersion("1.2.3"))
    XCTAssertFalse(AppVersion("1.2.4") < AppVersion("1.2.3"))
  }

  func testGreaterThanComparison() {
    XCTAssertFalse(AppVersion("2.0.0") < AppVersion("1.2.3"))
    XCTAssertFalse(AppVersion("1.3.0") < AppVersion("1.2.3"))
    XCTAssertFalse(AppVersion("1.2.4") < AppVersion("1.2.3"))

    XCTAssertTrue(AppVersion("1.2.3") < AppVersion("2.0.0"))
    XCTAssertTrue(AppVersion("1.2.3") < AppVersion("1.3.0"))
    XCTAssertTrue(AppVersion("1.2.3") < AppVersion("1.2.4"))
  }

}
