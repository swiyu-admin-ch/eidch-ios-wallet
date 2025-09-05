import BITJWT
import Factory
import Foundation
import XCTest
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// MARK: - SdJWSDecoderTests

// swiftlint: disable force_unwrapping

final class SdJWSTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringAllKeys_ReturnsWhole() throws {
    let sdJwt = TestSdJWTPayload.Mock.flat
    let keys = [Self.key1, Self.key2, Self.key3]

    let newSdJwt = sdJwt.createSelectiveDisclosure(for: keys)

    let expected = String(data: TestSdJWTPayload.Mock.flatJwtData, encoding: .utf8)!
    XCTAssertEqual(expected, newSdJwt)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringSomeKeys_ReturnsJwtWithRequiredDisclosures() throws {
    let sdJwt = TestSdJWTPayload.Mock.flat
    let keys = [Self.key2]

    let newSdJwt = sdJwt.createSelectiveDisclosure(for: keys)

    let expected = [sdJwt.rawJWS, TestSdJWTPayload.Mock.disclosure2, ""].joined(separator: SdJWSDecoder.sdJWTSeparator)
    XCTAssertEqual(expected, newSdJwt)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringNoKeys_ReturnsJwt() throws {
    let sdJwt = TestSdJWTPayload.Mock.flat
    let keys: [String] = []

    let newSdJwt = sdJwt.createSelectiveDisclosure(for: keys)

    XCTAssertEqual(sdJwt.rawJWS + SdJWSDecoder.sdJWTSeparator, newSdJwt)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringOtherKeys_ReturnsJwt() throws {
    let sdJwt = TestSdJWTPayload.Mock.flat
    let keys: [String] = ["otherKey", "otherKey2"]

    let newSdJwt = sdJwt.createSelectiveDisclosure(for: keys)

    XCTAssertEqual(sdJwt.rawJWS + SdJWSDecoder.sdJWTSeparator, newSdJwt)
  }

  // MARK: Private

  private static let key1 = "test_key_1"
  private static let key2 = "test_key_2"
  private static let key3 = "test_key_3"

}

// swiftlint: enable force_unwrapping
