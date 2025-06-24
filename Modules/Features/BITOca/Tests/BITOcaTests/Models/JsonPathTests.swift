import XCTest
@testable import BITOca

// MARK: - JsonPathTests

final class JsonPathTests: XCTestCase {

  // MARK: Internal

  func testInit_validJsonPaths_justRuns() throws {
    for rawJsonPath in validJsonPaths {
      XCTAssertNoThrow(try JsonPath(rawString: rawJsonPath))
    }
  }

  func testInit_invalidJsonPaths_throwsInvalidJsonPathError() throws {
    for rawJsonPath in invalidJsonPaths {
      XCTAssertThrowsError(try JsonPath(rawString: rawJsonPath)) { error in
        XCTAssertEqual(error as? OcaError, .invalidJsonPath)
      }
    }
  }

  func testEquals_equalJsonPaths_areEqual() throws {
    for (lhsPath, rhsPath) in equalJsonPaths {
      let lhs = try JsonPath(rawString: lhsPath)
      let rhs = try JsonPath(rawString: rhsPath)
      XCTAssertEqual(lhs, rhs)
      XCTAssertEqual(rhs, lhs)
    }
  }

  func testEquals_unequalJsonPaths_areNotEqual() throws {
    for (lhsPath, rhsPath) in unequalJsonPaths {
      let lhs = try JsonPath(rawString: lhsPath)
      let rhs = try JsonPath(rawString: rhsPath)
      XCTAssertNotEqual(lhs, rhs)
    }
  }

  // MARK: Private

  private let invalidJsonPaths = [
    // regular expression function
    "$..book[?(@.price <= $['expensive'])]",
    // function extension
    "$..book.length()",
    "$..book.length() ",
    "$..book.length()\t",
    "$..book.length()\n",
    "$.book.concat(foobar)",
    // negative array index
    "$.book[1].foo[-1].bar",
    "$.book[-1]",
    "$.book[-]",
    "$.book[-12345678 ]",
    "$.book[ -1 ]",
    "$.book[ - 1 ]",
    "$[-1]",
    "$.a[-99999999999999999999999999999999]",
    // name cannot start with a digit
    "$.123a",
    "$.x[\"123a\"]",
    "$['1x']",
    "$[\"1x\"]",
    // other errors
    "$[\"x']",
    "$[x]",
    "$..y",
    "$x",
    "$.",
    "$",
    "",
  ]

  private let validJsonPaths = [
    "$.x.y",
    "$['x']['y']",
    "$[\"x\"]['y']",
    "$.x[0]",
    "$.x[0]['y']",
    "$.x[0][\"y\"]",
    "$.x[0].y",
    "$.a[99999999999999999999999999999999]",
    "$['x'][0]",
    "$[\"x\"][0]",
    "$.x[*]",
    "$['x'][*]",
    "$[\"x\"][*]",
    "$.xyz[\"x1\"]",
    "$.x['x1']",
    "$.x[\"x1\"]",
    "$[\"a\"].avb[\"v123\"]",
  ]

  private let equalJsonPaths = [
    ("$.x", "$.x"),
    ("$.x", "$['x']"),
    ("$.x", "$[\"x\"]"),
    ("$['x']", "$['x']"),
    ("$['x']", "$[\"x\"]"),
    ("$[\"x\"]", "$[\"x\"]"),
    ("$.x[1]", "$.x[1]"),
    ("$.x[*]", "$.x[1]"),
    ("$.x[*]", "$.x[*]"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.a['b'][\"c\"].d[0].e[*].f[*]"),
  ]

  private let unequalJsonPaths = [
    ("$.x", "$.y"),
    ("$.x", "$['y']"),
    ("$.x", "$[\"y\"]"),
    ("$['x']", "$['y']"),
    ("$['x']", "$[\"y\"]"),
    ("$[\"x\"]", "$[\"y\"]"),
    ("$.x", "$.x.y"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.x['b'][\"c\"].d[0].e[*].f[*]"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.a['x'][\"c\"].d[0].e[*].f[*]"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.a['b'][\"x\"].d[0].e[*].f[*]"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.a['b'][\"c\"].x[0].e[*].f[*]"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.a['b'][\"c\"].d[1].e[*].f[*]"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.a['b'][\"c\"].d[0].x[*].f[*]"),
    ("$.a.b.c.d[0].e[1].f[*]", "$.a['b'][\"c\"].d[0].e[*].x[*]"),
  ]
}
