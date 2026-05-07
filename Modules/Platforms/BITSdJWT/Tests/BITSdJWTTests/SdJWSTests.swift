import BITJWT
import Factory
import Foundation
import XCTest
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - SdJWSDecoderTests

// swiftlint: disable force_unwrapping force_try implicitly_unwrapped_optional

final class SdJWSTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    sdJws = try! decoder.decode(FlatJWT.self, from: FlatJWT.Mock.data)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringAllKeys_ReturnsWhole() {
    let keys = [Self.key1, Self.key2, Self.key3]

    let newSdJwt = sdJws.createSelectiveDisclosure(for: keys)

    let splitSdJwt = newSdJwt.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 4)
    XCTAssertEqual(splitSdJwt[0], FlatJWT.Mock.JWS)
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure1))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure2))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure3))
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringSomeKeys_ReturnsJwtWithRequiredDisclosures() {
    let keys = [Self.key2]

    let newSdJwt = sdJws.createSelectiveDisclosure(for: keys)

    let expected = [sdJws.rawJWS, FlatJWT.Mock.disclosure2, ""].joined(separator: SdJWSDecoder.sdJWTSeparator)
    XCTAssertEqual(expected, newSdJwt)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringNoKeys_ReturnsJwt() {
    let keys = [String]()

    let newSdJwt = sdJws.createSelectiveDisclosure(for: keys)

    XCTAssertEqual(sdJws.rawJWS + SdJWSDecoder.sdJWTSeparator, newSdJwt)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringOtherKeys_ReturnsJwt() {
    let keys: [String] = ["otherKey", "otherKey2"]

    let newSdJwt = sdJws.createSelectiveDisclosure(for: keys)

    XCTAssertEqual(sdJws.rawJWS + SdJWSDecoder.sdJWTSeparator, newSdJwt)
  }

  // MARK: Private

  private static let key1 = "test_key_1"
  private static let key2 = "test_key_2"
  private static let key3 = "test_key_3"

  private let decoder = SdJWSDecoder()
  private var sdJws: SdJWS<FlatJWT>!

}

// swiftlint: enable force_unwrapping
