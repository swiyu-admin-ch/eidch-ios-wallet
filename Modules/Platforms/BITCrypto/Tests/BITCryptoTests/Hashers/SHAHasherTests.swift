import XCTest
@testable import BITCrypto

// MARK: - SHAHasherTests

final class SHAHasherTests: XCTestCase {

  func testHash_SHA256() throws {
    let data = try "123456".asData()
    let hash = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92"
    let hasher: BITCrypto.Hashable = SHA256Hasher()
    let result = hasher.hash(data)
    XCTAssertNotNil(result)
    XCTAssertEqual(hash, result.hexString)
  }

  func testHash_SHA384() throws {
    let data = try "123456".asData()
    let hash = "0a989ebc4a77b56a6e2bb7b19d995d185ce44090c13e2984b7ecc6d446d4b61ea9991b76a4c2f04b1b4d244841449454"
    let hasher: BITCrypto.Hashable = SHA384Hasher()
    let result = hasher.hash(data)
    XCTAssertNotNil(result)
    XCTAssertEqual(hash, result.hexString)
  }

  func testHash_SHA512() throws {
    let data = try "123456".asData()
    let hash = "ba3253876aed6bc22d4a6ff53d8406c6ad864195ed144ab5c87621b6c233b548baeae6956df346ec8c17f5ea10f35ee3cbc514797ed7ddd3145464e2a0bab413"
    let hasher: BITCrypto.Hashable = SHA512Hasher()
    let result = hasher.hash(data)
    XCTAssertNotNil(result)
    XCTAssertEqual(hash, result.hexString)
  }

  func testSalt_SHA256() throws {
    let data = try "123456".asData()
    let salt = try "46084f444652c40282fc8de1ae0868f4".asData()
    let hash = "6c77d95036a0b78066ef7b392c65ae1fc9e4af60baa8983869c02912395a0e0d"
    let hasher: BITCrypto.Hashable = SHA256Hasher()
    let result = hasher.salt(data, withSalt: salt)
    XCTAssertNotNil(result)
    XCTAssertEqual(hash, result.hexString)
  }

  func testSalt_SHA384() throws {
    let data = try "123456".asData()
    let salt = try "46084f444652c40282fc8de1ae0868f4".asData()
    let hash = "cfa50cc09586baebd268436ab2d396b94d0cfa3fb3cf67a5fadd64588b82b5c97052091d2fc16c59a61753f1418382fb"
    let hasher: BITCrypto.Hashable = SHA384Hasher()
    let result = hasher.salt(data, withSalt: salt)
    XCTAssertNotNil(result)
    XCTAssertEqual(hash, result.hexString)
  }

  func testSalt_SHA512() throws {
    let data = try "123456".asData()
    let salt = try "46084f444652c40282fc8de1ae0868f4".asData()
    let hash = "e9f9cf01d10cf34b1b1cf71053a9badf5d463f32e29d267e48bbef377233fd8767bb2e53af5ab7d2999830b45c08a92cda5e596eadfc1a39d30e57542d45e971"
    let hasher: BITCrypto.Hashable = SHA512Hasher()
    let result = hasher.salt(data, withSalt: salt)
    XCTAssertNotNil(result)
    XCTAssertEqual(hash, result.hexString)
  }

}
