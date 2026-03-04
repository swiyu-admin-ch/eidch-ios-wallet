import XCTest
@testable import BITCrypto

final class PBKDF2Tests: XCTestCase {

  // MARK: Internal

  func testDeriveKey_HmacSha256() throws {
    let data = try "123456".asData()

    let salt1 = try "846f5223407a1687eaa5bf937ba155e8d9900ec4f3caa8b14d84168a6d7a636b".asData()
    let salt2 = try "3698d0a944a360369e3df545ca914e67dcce90a01bcdc5fe92b703fe7cf50037".asData()

    let deriver1 = PBKDF2(using: .hmacSHA256, configuration: configuration)
    let result1 = try deriver1.deriveKey(from: data, with: salt1)
    XCTAssertNotNil(result1)
    XCTAssertTrue(!result1.isEmpty)

    let deriver2 = PBKDF2(using: .hmacSHA256, configuration: configuration)
    let result2 = try deriver2.deriveKey(from: data, with: salt1)
    XCTAssertNotNil(result2)
    XCTAssertTrue(!result2.isEmpty)
    XCTAssertEqual(result1, result2)

    let result3 = try deriver2.deriveKey(from: data, with: salt2)
    XCTAssertNotNil(result3)
    XCTAssertTrue(!result3.isEmpty)
    XCTAssertNotEqual(result1, result3)
  }

  func testDeriveKey_HmacSha512() throws {
    let data = try "123456".asData()

    let salt1 = try "846f5223407a1687eaa5bf937ba155e8d9900ec4f3caa8b14d84168a6d7a636b".asData()
    let salt2 = try "3698d0a944a360369e3df545ca914e67dcce90a01bcdc5fe92b703fe7cf50037".asData()

    let deriver1 = PBKDF2(using: .hmacSHA512, configuration: configuration)
    let result1 = try deriver1.deriveKey(from: data, with: salt1)
    XCTAssertNotNil(result1)
    XCTAssertTrue(!result1.isEmpty)

    let deriver2 = PBKDF2(using: .hmacSHA512, configuration: configuration)
    let result2 = try deriver2.deriveKey(from: data, with: salt1)
    XCTAssertNotNil(result2)
    XCTAssertTrue(!result2.isEmpty)
    XCTAssertEqual(result1, result2)

    let result3 = try deriver2.deriveKey(from: data, with: salt2)
    XCTAssertNotNil(result3)
    XCTAssertTrue(!result3.isEmpty)
    XCTAssertNotEqual(result1, result3)
  }

  // MARK: Private

  private let configuration = PBKDF2.Configuration(iterations: 10, keyLength: 32)

}
