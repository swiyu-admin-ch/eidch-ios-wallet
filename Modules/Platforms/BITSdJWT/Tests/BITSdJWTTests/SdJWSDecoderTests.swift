import Factory
import Foundation
import XCTest
@testable import BITJWT
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// MARK: - SdJWSDecoderTests

// swiftlint: disable force_unwrapping force_cast

final class SdJWSDecoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    decoder = SdJWSDecoder()
  }

  func testDecode_flat() throws {
    let data = TestSdJWT.Mock.flatJwtData
    mockJwsDecoder(sdJwtData: data)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    let expectedResolvedPayload = TestSdJWT.Mock.sampleJWT
    XCTAssertEqual(sdJWT.payload, Self.jwsPayloadMock)
    XCTAssertEqual(sdJWT.resolvedPayload, expectedResolvedPayload)
    XCTAssertEqual(sdJWT.rawPayload, TestSdJWT.Mock.flatJwtPayload)
    let payload = sdJWT.resolvedPayloadDictionary
    XCTAssertEqual(payload.count, 3)
    expectedResolvedPayload.assertIn(payload)

    XCTAssertEqual(sdJWT.header, headerMock)
    XCTAssertEqual(sdJWT.rawSdJWS, String(data: data, encoding: .utf8))
    XCTAssertEqual(sdJWT.rawJWS, data.parseJWS())
    assertFlatClaims(sdJWT.disclosableClaims, expectedPayload: disclosedPayloadMock)
  }

  func testDecode_flatWithIsoDate() throws {
    let data = TestSdJWT.Mock.flatJwtWithIsoDateData
    var decoderMock = JWSDecoderMock(jwt: TestDatePayload(), rawPayload: TestSdJWT.Mock.flatJwtWithIsoDatePayload)
    decoderMock.expectedInput = data.parseJWS()
    Container.shared.jwsDecoder.register { decoderMock }
    decoder = SdJWSDecoder()

    decoder.dateDecodingStrategy = .iso8601

    let sdJWT = try decoder.decode(TestDatePayload.self, from: data)

    XCTAssertEqual(sdJWT.resolvedPayload, TestDatePayload(date: Date(timeIntervalSinceReferenceDate: 0)))
  }

  func testDecode_flatWithKeyBinding() throws {
    let data = TestSdJWT.Mock.flatJwtWithKeyBindingData
    mockJwsDecoder(sdJwtData: data)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    let expectedPayload = TestSdJWT.Mock.sampleJWT
    XCTAssertEqual(sdJWT.payload, Self.jwsPayloadMock)
    XCTAssertEqual(sdJWT.resolvedPayload, expectedPayload)
    XCTAssertEqual(sdJWT.header, headerMock)
    XCTAssertEqual(sdJWT.rawSdJWS, String(data: data, encoding: .utf8))
    XCTAssertEqual(sdJWT.rawJWS, data.parseJWS())
    assertFlatClaims(sdJWT.disclosableClaims, expectedPayload: disclosedPayloadMock)
  }

  func testDecode_flatWithNullClaims() throws {
    let data = TestSdJWT.Mock.flatJwtWithNullClaims
    let expectedPayload = TestSdJWT()
    mockJwsDecoder(sdJwtData: data, payload: expectedPayload, rawPayload: TestSdJWT.Mock.flatJwtWithNullClaimsPayload)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    XCTAssertEqual(sdJWT.payload, expectedPayload)
    XCTAssertEqual(sdJWT.resolvedPayload, expectedPayload)
    XCTAssertEqual(sdJWT.header, headerMock)
    XCTAssertEqual(sdJWT.rawSdJWS, String(data: data, encoding: .utf8))
    XCTAssertEqual(sdJWT.rawJWS, data.parseJWS())

    let payload = sdJWT.resolvedPayloadDictionary
    XCTAssertEqual(payload.count, 2)
    XCTAssertTrue(payload.keys.contains(TestSdJWT.CodingKeys.testValue1.rawValue))
    XCTAssertTrue(payload.keys.contains(TestSdJWT.CodingKeys.testValue2.rawValue))
    XCTAssertNil(payload[TestSdJWT.CodingKeys.testValue1.rawValue] as? String)
    XCTAssertNil(payload[TestSdJWT.CodingKeys.testValue2.rawValue] as? String)

    let claims = sdJWT.disclosableClaims
    XCTAssertEqual(claims.count, 1)
    XCTAssertEqual(claims[0].key, Self.key1)
    XCTAssertNil(claims[0].value)
  }

  func testDecode_flatUsingSha384() throws {
    let data = TestSdJWT.Mock.flatJwtUsingSha384
    mockJwsDecoder(sdJwtData: data, payload: TestSdJWT(), rawPayload: TestSdJWT.Mock.flatJwtUsingSha384Payload)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    let expectedPayload = TestSdJWT(testValue1: "test_value_1")
    XCTAssertEqual(sdJWT.resolvedPayload, expectedPayload)
    XCTAssertEqual(sdJWT.rawJWS, data.parseJWS())

    XCTAssertEqual(sdJWT.disclosableClaims.count, 1)
    let claim = sdJWT.disclosableClaims[0]
    XCTAssertEqual(claim.key, Self.key1)
    XCTAssertEqual(claim.value?.rawValue, "test_value_1")
    XCTAssertEqual(claim.disclosure, TestSdJWT.Mock.disclosure1)
    XCTAssertEqual(claim.digest, "ouLWzsH--wYNXVB1qPDj3-MLkmI0JwbNvmuzz1RHMzcF4ut5P03wauYCqtEbynou")
  }

  func testDecode_flatUsingSha512() throws {
    let data = TestSdJWT.Mock.flatJwtUsingSha512
    mockJwsDecoder(sdJwtData: data, payload: TestSdJWT(), rawPayload: TestSdJWT.Mock.flatJwtUsingSha512Payload)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    let expectedPayload = TestSdJWT(testValue1: "test_value_1")
    XCTAssertEqual(sdJWT.resolvedPayload, expectedPayload)
    XCTAssertEqual(sdJWT.rawJWS, data.parseJWS())

    XCTAssertEqual(sdJWT.disclosableClaims.count, 1)
    let claim = sdJWT.disclosableClaims[0]
    XCTAssertEqual(claim.key, Self.key1)
    XCTAssertEqual(claim.value?.rawValue, "test_value_1")
    XCTAssertEqual(claim.disclosure, TestSdJWT.Mock.disclosure1)
    XCTAssertEqual(claim.digest, "h-hqZBKqJLOcSrDjjYz8vj34x9cLrEg3DDv7dkFs3CP0OgtmU-cpkInCOaa4TSAOozys4LUouw-jPmNK-3KzlQ")
  }

  func testDecode_undisclosed() throws {
    let data = TestSdJWT.Mock.undisclosedJwtData
    let expectedPayload = TestSdJWT.Mock.sampleJWT
    mockJwsDecoder(sdJwtData: data, payload: expectedPayload, rawPayload: TestSdJWT.Mock.undisclosedJwtPayload)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    XCTAssertEqual(sdJWT.payload, expectedPayload)
    XCTAssertEqual(sdJWT.resolvedPayload, expectedPayload)
    let payload = sdJWT.resolvedPayloadDictionary
    XCTAssertEqual(payload.count, 3)
    expectedPayload.assertIn(payload)

    XCTAssertEqual(sdJWT.header, headerMock)
    XCTAssertTrue(sdJWT.disclosableClaims.isEmpty)
    XCTAssertEqual(sdJWT.rawJWS, data.parseJWS())
  }

  func testDecode_undisclosedWithKeyBinding() throws {
    let data = TestSdJWT.Mock.undisclosedJwtWithKeyBindingData
    let expectedPayload = TestSdJWT.Mock.sampleJWT
    mockJwsDecoder(sdJwtData: data, payload: expectedPayload, rawPayload: TestSdJWT.Mock.undisclosedJwtPayload)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    XCTAssertEqual(sdJWT.payload, expectedPayload)
    XCTAssertEqual(sdJWT.resolvedPayload, expectedPayload)
    XCTAssertTrue(sdJWT.disclosableClaims.isEmpty)
    XCTAssertEqual(sdJWT.rawJWS, data.parseJWS())
  }

  func testDecode_URLUnsafeRawRepresentable() throws {
    let data = TestSdJWT.Mock.jwtWithSpecialCharacterClaims
    mockJwsDecoder(sdJwtData: data, payload: TestSdJWT(), rawPayload: TestSdJWT.Mock.jwtWithSpecialCharacterClaimsPayload)

    let sdJWT = try decoder.decode(TestSdJWT.self, from: data)

    XCTAssertEqual(sdJWT.disclosableClaims.count, 1)
  }

  func testDecode_invalidSdJwt_throwsError() throws {
    let data = "HEADER.PAYLOAD.SIGNATURE".data(using: .utf8)!
    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_randomString_throwsError() throws {
    let data = "foobar".data(using: .utf8)!
    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_notString_throwsError() throws {
    let data = Data([0xA0])
    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_emptyData_throwsError() throws {
    let data = Data()
    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_unsupportedDigestAlgorithm_throwsError() throws {
    let data = TestSdJWT.Mock.unsupportedDigestAlgorithmData

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .unsupportedDigestAlgorithm)
    }
  }

  func testDecode_invalidDigests_throwsError() throws {
    let data = TestSdJWT.Mock.invalidDigestsData

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidDigests)
    }
  }

  func testDecode_duplicateDigest_throwsError() throws {
    let data = TestSdJWT.Mock.duplicateDigestData

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidDigests)
    }
  }

  func testDecode_digestNotFound_throwsError() throws {
    let data = TestSdJWT.Mock.digestNotFoundData

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .digestNotFound)
    }
  }

  func testDecode_onePartDisclosure_throwsError() throws {
    // ["test_salt_1"]
    let sdJwt = createInvalidDisclosureSdJwt(disclosure: "WyJ0ZXN0X3NhbHRfMSJd")
    let data = try XCTUnwrap(sdJwt.data(using: .utf8))

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidDisclosure)
    }
  }

  func testDecode_twoPartDisclosure_throwsError() throws {
    // ["test_salt_1", "test_key_1"]
    let sdJwt = createInvalidDisclosureSdJwt(disclosure: "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIl0")
    let data = try XCTUnwrap(sdJwt.data(using: .utf8))

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidDisclosure)
    }
  }

  func testDecode_tooManyPartsDisclosure_throwsError() throws {
    // ["test_salt_1", "test_key_1", "test_value_1", "test"]
    let sdJwt = createInvalidDisclosureSdJwt(disclosure: "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIiwgInRlc3RfdmFsdWVfMSIsICJ0ZXN0Il0")
    let data = try XCTUnwrap(sdJwt.data(using: .utf8))

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidDisclosure)
    }
  }

  func testDecode_claimAlreadyExists_throwsError() throws {
    let data = TestSdJWT.Mock.claimAlreadyExistsData

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .claimAlreadyExists)
    }
  }

  func testDecode_strictPayloadDecodingWithAddtionalClaims_throwsError() throws {
    let data = TestSdJWT.Mock.flatJwtData
    decoder = SdJWSDecoder(strictPayloadDecoding: true)

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidJWTPayload)
    }
  }

  func testDecode_decoder_throwsError() throws {
    let data = TestSdJWT.Mock.flatJwtData
    mockJwsDecoder(throwingError: TestingError.error)

    XCTAssertThrowsError(try decoder.decode(TestSdJWT.self, from: data)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let key1 = "test_key_1"
  private static let key2 = "test_key_2"
  private static let key3 = "test_key_3"
  private static let jwsPayloadMock = TestSdJWT(testValue3: "test_value_3")

  private let disclosedPayloadMock = TestSdJWT(testValue1: "test_value_1", testValue2: "test_value_2")
  private let headerMock = JWSHeader(algorithm: .ES256, keyIdentifier: "keyIdentifier")

  private var decoder = SdJWSDecoder()

  private func mockJwsDecoder(sdJwtData: Data? = nil, payload: TestSdJWT = jwsPayloadMock, rawPayload: String = TestSdJWT.Mock.flatJwtPayload, throwingError: Error? = nil) {
    var decoderMock = JWSDecoderMock(jwt: payload, rawPayload: rawPayload)
    decoderMock.header = headerMock
    if let data = sdJwtData {
      decoderMock.expectedInput = data.parseJWS()
    }
    decoderMock.throwingError = throwingError
    Container.shared.jwsDecoder.register { decoderMock }
    decoder = SdJWSDecoder()
  }

  private func assertFlatClaims(_ claims: [SdJWTClaim], expectedPayload: TestSdJWT) {
    if let testValue1 = expectedPayload.testValue1 {
      let claim = claims.first { $0.key == Self.key1 }!
      XCTAssertEqual(claim.value?.rawValue, testValue1)
      XCTAssertEqual(claim.disclosure, TestSdJWT.Mock.disclosure1)
      XCTAssertEqual(claim.digest, TestSdJWT.Mock.digest1)
    } else {
      XCTAssertNil(claims.first { $0.key == Self.key1 })
    }
    if let testValue2 = expectedPayload.testValue2 {
      let claim = claims.first { $0.key == Self.key2 }!
      XCTAssertEqual(claim.value?.rawValue, testValue2)
      XCTAssertEqual(claim.disclosure, TestSdJWT.Mock.disclosure2)
      XCTAssertEqual(claim.digest, TestSdJWT.Mock.digest2)
    } else {
      XCTAssertNil(claims.first { $0.key == Self.key2 })
    }
    if let testValue3 = expectedPayload.testValue3 {
      let claim = claims.first { $0.key == Self.key3 }!
      XCTAssertEqual(claim.value?.rawValue, testValue3)
      XCTAssertEqual(claim.disclosure, TestSdJWT.Mock.disclosure3)
      XCTAssertEqual(claim.digest, TestSdJWT.Mock.digest3)
    } else {
      XCTAssertNil(claims.first { $0.key == Self.key3 })
    }
  }

  private func createInvalidDisclosureSdJwt(disclosure: String) -> String {
    TestSdJWT.Mock.flatJwtData.parseJWS() + SdJWSDecoder.sdJWTSeparator + disclosure + SdJWSDecoder.sdJWTSeparator
  }

}

extension Data {
  fileprivate func parseJWS() -> String {
    let rawSdJwt = String(data: self, encoding: .utf8)!
    return String(rawSdJwt.split(separator: SdJWSDecoder.sdJWTSeparator)[0])
  }
}

// MARK: - TestDatePayload

private struct TestDatePayload: JWT {

  // MARK: Lifecycle

  init(date: Date? = nil) {
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

  private let date: Date?

}

extension TestSdJWT {

  fileprivate func assertIn(_ dictionary: [String: Any?]) {
    XCTAssertEqual(dictionary[TestSdJWT.CodingKeys.testValue1.rawValue] as? String, testValue1)
    XCTAssertEqual(dictionary[TestSdJWT.CodingKeys.testValue2.rawValue] as? String, testValue2)
    XCTAssertEqual(dictionary[TestSdJWT.CodingKeys.testValue3.rawValue] as? String, testValue3)
  }
}

// swiftlint: enable force_unwrapping force_cast
