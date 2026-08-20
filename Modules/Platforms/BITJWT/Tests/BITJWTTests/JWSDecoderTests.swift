import Foundation
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
    let data = RegisteredClaimsJWT.Mock.sampleData

    let jws = try decoder.decode(RegisteredClaimsJWT.self, from: data)

    let expectedData = RegisteredClaimsJWT.Mock.registeredClaims
    XCTAssertEqual(jws.payload, expectedData)
    try assertRawPayload(jws.rawPayload, expectedData: expectedData)

    XCTAssertEqual(jws.header.algorithm, JWTAlgorithm.ES512)
    XCTAssertEqual(jws.header.type, "jwt")
    XCTAssertEqual(jws.header.keyIdentifier, "keyIdentifier")
    XCTAssertEqual(jws.header.jwk, RegisteredClaimsJWT.Mock.jwk)
  }

  func testDecode_ValidJWSWithIsoDate_ReturnsJWS() throws {
    let data = RegisteredClaimsJWT.Mock.sampleIsoDate
    decoder.dateDecodingStrategy = .iso8601

    let jws = try decoder.decode(TestDatePayload.self, from: data)

    XCTAssertEqual(jws.payload, TestDatePayload(date: Date(timeIntervalSinceReferenceDate: 0)))
    XCTAssertEqual(jws.header.algorithm, JWTAlgorithm.ES512)
    XCTAssertEqual(jws.header.type, "test")
    XCTAssertNil(jws.header.keyIdentifier)
    XCTAssertNil(jws.header.jwk)
  }

  func testDecode_ValidJWSWithNoType_ReturnsJWS() throws {
    let data = RegisteredClaimsJWT.Mock.noTypeData

    let jws = try decoder.decode(TestEmptyPayload.self, from: data)

    XCTAssertEqual(jws.header.algorithm, JWTAlgorithm.ES512)
    XCTAssertNil(jws.header.type)
    XCTAssertNil(jws.header.keyIdentifier)
    XCTAssertNil(jws.header.jwk)
  }

  func testDecode_InvalidJWS_ThrowsError() throws {
    let data = "invalid".data(using: .utf8)!

    XCTAssertThrowsError(try decoder.decode(RegisteredClaimsJWT.self, from: data)) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testDecode_NoneAlgorithm_ThrowsError() throws {
    let data = RegisteredClaimsJWT.Mock.noneAlgorithmData

    XCTAssertThrowsError(try decoder.decode(RegisteredClaimsJWT.self, from: data)) { error in
      let decodingError = error as? DecodingError
      guard let decodingError, case .dataCorrupted = decodingError else {
        XCTFail("Wrong error thrown: \(error)")
        return
      }
    }
  }

  func testDecode_InvalidAlgorithm_ThrowsError() throws {
    let data = RegisteredClaimsJWT.Mock.invalidAlgorithmData

    XCTAssertThrowsError(try decoder.decode(RegisteredClaimsJWT.self, from: data)) { error in
      XCTAssertEqual(error as? JWSDecoderError, .algorithmNotFound)
    }
  }

  func testDecode_InvalidType_ThrowsError() throws {
    let data = RegisteredClaimsJWT.Mock.invalidTypeData

    XCTAssertThrowsError(try decoder.decode(RegisteredClaimsJWT.self, from: data)) { error in
      XCTAssertEqual(error as? JWSDecoderError, .invalidType)
    }
  }

  func testDecode_ValidJWSWithAlternativeAcceptedType_ReturnsJWS() throws {
    let data = RegisteredClaimsJWT.Mock.invalidTypeData

    let jws = try decoder.decode(TestAlternativeTypePayload.self, from: data)

    XCTAssertEqual(jws.header.type, "invalid")
    XCTAssertEqual(jws.payload.test, "value")
  }

  func testDecode_MissingTypeWithAcceptedTypes_ThrowsError() throws {
    let data = RegisteredClaimsJWT.Mock.noTypeData

    XCTAssertThrowsError(try decoder.decode(TestTypedEmptyPayload.self, from: data)) { error in
      XCTAssertEqual(error as? JWSDecoderError, .invalidType)
    }
  }

  // MARK: Private

  private var decoder = JWSDecoder()

  private func assertRawPayload(_ rawPayload: String, expectedData: RegisteredClaimsJWT) throws {
    let rawPayloadData = rawPayload.data(using: .utf8)!
    let payload = try JSONSerialization.jsonObject(with: rawPayloadData, options: []) as! [String: Any]
    XCTAssertEqual(payload.count, 7)
    XCTAssertEqual(payload[RegisteredClaimsJWT.CodingKeys.issuer.rawValue] as? String, expectedData.issuer)
    XCTAssertEqual(payload[RegisteredClaimsJWT.CodingKeys.subject.rawValue] as? String, expectedData.subject)
    XCTAssertEqual(payload[RegisteredClaimsJWT.CodingKeys.audience.rawValue] as? String, expectedData.audience)
    XCTAssertEqual(payload[RegisteredClaimsJWT.CodingKeys.expiredAt.rawValue] as? TimeInterval, expectedData.expiredAt?.timeIntervalSince1970)
    XCTAssertEqual(payload[RegisteredClaimsJWT.CodingKeys.activatedAt.rawValue] as? TimeInterval, expectedData.activatedAt?.timeIntervalSince1970)
    XCTAssertEqual(payload[RegisteredClaimsJWT.CodingKeys.issuedAt.rawValue] as? TimeInterval, expectedData.issuedAt?.timeIntervalSince1970)
    XCTAssertEqual(payload["test"] as? String, "value")
  }

}

// MARK: - TestDatePayload

private struct TestDatePayload: JWT {

  // MARK: Lifecycle

  init(date: Date) {
    self.date = date
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case date
  }

  let type: String? = "test"

  var issuer: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var subject: String? {
    nil
  }

  var issuedAt: Date? {
    nil
  }

  var expiredAt: Date? {
    nil
  }

  var activatedAt: Date? {
    nil
  }

  // MARK: Private

  private let date: Date

}

// MARK: - TestEmptyPayload

private struct TestEmptyPayload: JWT {

  enum CodingKeys: CodingKey {}

  let type: String? = nil

  var issuer: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var subject: String? {
    nil
  }

  var issuedAt: Date? {
    nil
  }

  var expiredAt: Date? {
    nil
  }

  var activatedAt: Date? {
    nil
  }

}

// MARK: - TestAlternativeTypePayload

private struct TestAlternativeTypePayload: JWT {

  enum CodingKeys: String, CodingKey {
    case test
  }

  let test: String

  let type: String? = "test"

  var acceptedTypes: [String]? {
    [type, "invalid"].compactMap { $0 }
  }

  var issuer: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var subject: String? {
    nil
  }

  var issuedAt: Date? {
    nil
  }

  var expiredAt: Date? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}

// MARK: - TestTypedEmptyPayload

private struct TestTypedEmptyPayload: JWT {

  enum CodingKeys: CodingKey {}

  let type: String? = "test"

  var issuer: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var subject: String? {
    nil
  }

  var issuedAt: Date? {
    nil
  }

  var expiredAt: Date? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}

// swiftlint: enable force_unwrapping force_cast
