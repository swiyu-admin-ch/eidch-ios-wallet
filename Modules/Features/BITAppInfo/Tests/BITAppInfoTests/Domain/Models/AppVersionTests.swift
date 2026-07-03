import Foundation
import XCTest
@testable import BITAppInfo

class AppVersionTests: XCTestCase {

  func test_rawValues() {
    let version = "1.0.0"
    let appVersion = Version(version)

    XCTAssertEqual(appVersion.rawValue, version)
    XCTAssertEqual(appVersion.major, 1)
    XCTAssertEqual(appVersion.minor, 0)
    XCTAssertEqual(appVersion.patch, 0)
  }

  func testEquality() {
    let version1 = Version("1.2.3")
    let version2 = Version("1.2.3")
    XCTAssertEqual(version1, version2)

    let version3 = Version("1.2.4")
    XCTAssertNotEqual(version1, version3)
  }

  func testInequalityDifferentMajor() {
    let version1 = Version("1.2.3")
    let version2 = Version("2.2.3")
    XCTAssertNotEqual(version1, version2)

    let version3 = Version("1.2.3")
    XCTAssertEqual(version1, version3)
  }

  func testInequalityDifferentMinor() {
    let version1 = Version("1.2.3")
    let version2 = Version("1.3.3")
    XCTAssertNotEqual(version1, version2)

    let version3 = Version("1.2.3")
    XCTAssertEqual(version1, version3)
  }

  func testInequalityDifferentPatch() {
    let version1 = Version("1.2.3")
    let version2 = Version("1.2.4")
    XCTAssertNotEqual(version1, version2)

    let version3 = Version("1.2.3")
    XCTAssertEqual(version1, version3)
  }

  func testLessThanComparison() {
    XCTAssertTrue(Version("0.1.1") < Version("0.1.2"))
    XCTAssertTrue(Version("0.0.1") < Version("0.0.2"))
    XCTAssertTrue(Version("1.2.3") < Version("2.0.0"))
    XCTAssertTrue(Version("1.2.3") < Version("1.3.0"))
    XCTAssertTrue(Version("1.2.3") < Version("1.2.4"))

    XCTAssertFalse(Version("2.0.0") < Version("1.2.3"))
    XCTAssertFalse(Version("1.3.0") < Version("1.2.3"))
    XCTAssertFalse(Version("1.2.4") < Version("1.2.3"))
  }

  func testGreaterThanComparison() {
    XCTAssertFalse(Version("2.0.0") < Version("1.2.3"))
    XCTAssertFalse(Version("1.3.0") < Version("1.2.3"))
    XCTAssertFalse(Version("1.2.4") < Version("1.2.3"))

    XCTAssertTrue(Version("1.2.3") < Version("2.0.0"))
    XCTAssertTrue(Version("1.2.3") < Version("1.3.0"))
    XCTAssertTrue(Version("1.2.3") < Version("1.2.4"))
  }

}
