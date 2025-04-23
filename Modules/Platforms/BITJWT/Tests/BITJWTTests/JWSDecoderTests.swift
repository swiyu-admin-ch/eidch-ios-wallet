import Foundation
import JOSESwift
import XCTest
@testable import BITJWT

// MARK: - JWSDecoderTests

// swiftlint: disable force_unwrapping force_cast

final class JWSDecoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    decoder = JWSDecoder()
  }

  func testDecode_ValidJWS_ReturnsJWS() throws {
    let data = JWTRegisteredPayload.Mock.sampleData

    let jws = try decoder.decode(JWTRegisteredPayload.self, from: data)

    let expectedData = JWTRegisteredPayload.Mock.registeredPayload
    XCTAssertEqual(jws.payload, expectedData)
    try assertRawPayload(jws.rawPayload, expectedData: expectedData)

    XCTAssertEqual(jws.header.algorithm, JWTAlgorithm.ES512)
    XCTAssertEqual(jws.header.type, "jwt")
    XCTAssertEqual(jws.header.keyIdentifier, "keyIdentifier")
    XCTAssertEqual(jws.header.jwk, JWTRegisteredPayload.Mock.jwk)
  }

  func testDecode_ValidJWSWithIsoDate_ReturnsJWS() throws {
    let data = JWTRegisteredPayload.Mock.sampleIsoDate
    decoder.dateDecodingStrategy = .iso8601

    let jws = try decoder.decode(TestDatePayload.self, from: data)

    XCTAssertEqual(jws.payload, TestDatePayload(date: Date(timeIntervalSinceReferenceDate: 0)))
    XCTAssertEqual(jws.header.algorithm, JWTAlgorithm.ES512)
    XCTAssertEqual(jws.header.type, "test")
    XCTAssertNil(jws.header.keyIdentifier)
    XCTAssertNil(jws.header.jwk)
  }

  func testDecode_ValidJWSWithNoType_ReturnsJWS() throws {
    let data = JWTRegisteredPayload.Mock.noTypeData

    let jws = try decoder.decode(TestEmptyPayload.self, from: data)

    XCTAssertEqual(jws.header.algorithm, JWTAlgorithm.ES512)
    XCTAssertNil(jws.header.type)
    XCTAssertNil(jws.header.keyIdentifier)
    XCTAssertNil(jws.header.jwk)
  }

  func testDecode_InvalidJWS_ThrowsError() throws {
    let data = "invalid".data(using: .utf8)!

    XCTAssertThrowsError(try decoder.decode(JWTRegisteredPayload.self, from: data)) { error in
      XCTAssertTrue(error is JOSESwiftError)
    }
  }

  func testDecode_NoneAlgorithm_ThrowsError() throws {
    let data = JWTRegisteredPayload.Mock.noneAlgorithmData

    XCTAssertThrowsError(try decoder.decode(JWTRegisteredPayload.self, from: data)) { error in
      XCTAssertTrue(error is JOSESwiftError)
    }
  }

  func testDecode_InvalidAlgorithm_ThrowsError() throws {
    let data = JWTRegisteredPayload.Mock.invalidAlgorithmData

    XCTAssertThrowsError(try decoder.decode(JWTRegisteredPayload.self, from: data)) { error in
      XCTAssertEqual(error as? JWSDecoderError, .algorithmNotFound)
    }
  }

  func testDecode_InvalidType_ThrowsError() throws {
    let data = JWTRegisteredPayload.Mock.invalidTypeData

    XCTAssertThrowsError(try decoder.decode(JWTRegisteredPayload.self, from: data)) { error in
      XCTAssertEqual(error as? JWSDecoderError, .invalidType)
    }
  }

  // MARK: Private

  private var decoder = JWSDecoder()

  private func assertRawPayload(_ rawPayload: String, expectedData: JWTRegisteredPayload) throws {
    let rawPayloadData = rawPayload.data(using: .utf8)!
    let payload = try JSONSerialization.jsonObject(with: rawPayloadData, options: []) as! [String: Any]
    XCTAssertEqual(payload.count, 7)
    XCTAssertEqual(payload[JWTRegisteredPayload.CodingKeys.issuer.rawValue] as? String, expectedData.issuer)
    XCTAssertEqual(payload[JWTRegisteredPayload.CodingKeys.subject.rawValue] as? String, expectedData.subject)
    XCTAssertEqual(payload[JWTRegisteredPayload.CodingKeys.audience.rawValue] as? String, expectedData.audience)
    XCTAssertEqual(payload[JWTRegisteredPayload.CodingKeys.expiredAt.rawValue] as? TimeInterval, expectedData.expiredAt?.timeIntervalSince1970)
    XCTAssertEqual(payload[JWTRegisteredPayload.CodingKeys.activatedAt.rawValue] as? TimeInterval, expectedData.activatedAt?.timeIntervalSince1970)
    XCTAssertEqual(payload[JWTRegisteredPayload.CodingKeys.issuedAt.rawValue] as? TimeInterval, expectedData.issuedAt?.timeIntervalSince1970)
    XCTAssertEqual(payload["test"] as? String, "value")
  }

}

// MARK: - TestDatePayload

private struct TestDatePayload: JWTPayload & Codable & Equatable {

  let type: String? = "test"
  private let date: Date

  init(date: Date) {
    self.date = date
  }

  enum CodingKeys: String, CodingKey {
    case date
  }

}

// MARK: - TestEmptyPayload

private struct TestEmptyPayload: JWTPayload & Codable & Equatable {

  let type: String? = nil

  enum CodingKeys: CodingKey {}

}

// swiftlint: enable force_unwrapping force_cast
