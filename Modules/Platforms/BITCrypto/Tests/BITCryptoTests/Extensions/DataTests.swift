import XCTest
@testable import BITCrypto

// MARK: - EncrypterTests

final class DataTests: XCTestCase {

  func testRandom32Bytes() throws {
    let length = 32
    let randomData = try Data.random(length: length)
    XCTAssertEqual(randomData.hexString.count, length * 2) // 2 chars is 1 byte
  }

  func testRandom64Bytes() throws {
    let length = 64
    let randomData = try Data.random(length: length)
    XCTAssertEqual(randomData.hexString.count, length * 2) // 2 chars is 1 byte
  }

}
