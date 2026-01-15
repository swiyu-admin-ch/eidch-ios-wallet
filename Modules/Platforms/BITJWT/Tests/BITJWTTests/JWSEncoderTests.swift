import Foundation
import JOSESwift
import XCTest
@testable import BITJWT
@testable import BITTestingCore
@testable import BITVault

// MARK: - JWSEncoderTests

final class JWSEncoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    encoder = JWSEncoder()
  }

  func testEncode_EncodePayloadAndDecode_PayloadAndHeaderFieldsMatch() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims

    let jws = try encoder.encode(payload, using: mockKeyPair)

    let decoded = try JWSDecoder().decode(RegisteredClaimsJWT.self, from: jws)
    XCTAssertEqual(decoded.payload, payload)
    XCTAssertEqual(decoded.header.algorithm.rawValue, mockKeyPair.algorithm.rawValue)
    XCTAssertNil(decoded.header.keyIdentifier)
    XCTAssertEqual(decoded.header.type, payload.type)

    guard let keyComponents = try mockKeyPair.publicKey?.ecPublicKeyComponents(), let jwk = decoded.header.jwk else {
      fatalError("Failed to parse JWK")
    }
    XCTAssertEqual(jwk.crv, keyComponents.crv)
    XCTAssertEqual(jwk.x.data(using: .utf8), keyComponents.x.base64URLEncodedData())
    XCTAssertEqual(jwk.y.data(using: .utf8), keyComponents.y.base64URLEncodedData())
  }

  func testEncode_EncodePayloadAndDecodeNoneKeyEncodingStrategy_PayloadAndHeaderFieldsMatch() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    encoder.keyEncodingStrategy = .none

    let jws = try encoder.encode(payload, using: mockKeyPair)

    let decoded = try JWSDecoder().decode(RegisteredClaimsJWT.self, from: jws)
    XCTAssertEqual(decoded.payload, payload)
    XCTAssertEqual(decoded.header.algorithm.rawValue, mockKeyPair.algorithm.rawValue)
    XCTAssertNil(decoded.header.keyIdentifier)
    XCTAssertEqual(decoded.header.type, payload.type)
    XCTAssertNil(decoded.header.jwk)
  }

  func testEncode_EncodePayloadAndDecodeIsoDateEncodingStrategy_PayloadAndHeaderFieldsMatch() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    encoder.keyEncodingStrategy = .none
    encoder.dateEncodingStrategy = .iso8601
    let decoder = JWSDecoder(dateDecodingStrategy: .iso8601)

    let jws = try encoder.encode(payload, using: mockKeyPair)

    let decoded = try decoder.decode(RegisteredClaimsJWT.self, from: jws)
    XCTAssertEqual(decoded.payload, payload)
    XCTAssertEqual(decoded.header.algorithm.rawValue, mockKeyPair.algorithm.rawValue)
    XCTAssertNil(decoded.header.keyIdentifier)
    XCTAssertEqual(decoded.header.type, payload.type)
    XCTAssertNil(decoded.header.jwk)
  }

  func testEncode_JwkCannotBeCreated_ThrowsError() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    let privateKey = SecKeyTestsHelper.createPrivateKey(type: kSecAttrKeyTypeRSA as String)
    let invalidKeyPair = VaultKeyPair(
      identifier: UUID().uuidString,
      privateKey: privateKey,
      algorithm: .eciesEncryptionStandardVariableIVX963SHA512AESGCM)

    XCTAssertThrowsError(try encoder.encode(payload, using: invalidKeyPair)) { error in
      XCTAssertEqual(error as? JWSEncoderError, .cannotCreateJwk)
    }
  }

  func testEncode_withAdditionalHeaderParameter_encodes() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    let additionalHeaderParameters: [String: Any] = ["key_attestation": "key_attestation_value"]

    let jws = try encoder.encode(payload, using: mockKeyPair, additionalHeaderParameters: additionalHeaderParameters)

    let decoded = try JOSESwift.JWS(compactSerialization: jws)
    let headerData = decoded.header.data()
    let json = try? JSONSerialization.jsonObject(with: headerData, options: [])
    let parameters = json as? [String: Any]

    XCTAssertEqual(parameters?["key_attestation"] as? String, "key_attestation_value")
  }

  func testEncode_withMultipleAdditionalHeaderParameter_merges() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    let additionalHeaderParameters: [String: Any] = [
      "key_attestation": "key_attestation_value",
      "foo": 1234,
    ]

    let jws = try encoder.encode(payload, using: mockKeyPair, additionalHeaderParameters: additionalHeaderParameters)

    let decoded = try JOSESwift.JWS(compactSerialization: jws)
    let headerData = decoded.header.data()
    let json = try? JSONSerialization.jsonObject(with: headerData, options: [])
    let parameters = json as? [String: Any]

    XCTAssertEqual(parameters?["key_attestation"] as? String, "key_attestation_value")
    XCTAssertEqual(parameters?["foo"] as? Int, 1234)
  }

  // MARK: Private

  private var encoder = JWSEncoder()
  private let mockKeyPair = VaultKeyPair.Mock.ES512
}
