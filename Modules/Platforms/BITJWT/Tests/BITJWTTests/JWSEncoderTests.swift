import Foundation
import JWSETKit
import XCTest
@testable import BITCrypto
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

    guard let publicKey = mockKeyPair.publicKey, let jwk = decoded.header.jwk else {
      fatalError("Failed to parse JWK")
    }
    XCTAssertEqual(jwk, try JWK(from: publicKey))
    XCTAssertNoThrow(try JWSSignatureValidator().validate(decoded, with: jwk))
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

  func testEncode_withAdditionalHeaderParameter_encodes() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    let additionalHeaderParameters: [String: Any] = ["key_attestation": "key_attestation_value"]

    let jws = try encoder.encode(payload, using: mockKeyPair, additionalHeaderParameters: additionalHeaderParameters)

    let decoded = try JSONWebSignaturePlain(from: jws)
    let parameter: String? = decoded.header["key_attestation"]

    XCTAssertEqual(parameter, "key_attestation_value")
  }

  func testEncodeJWS_withAdditionalHeaderParameter_encodes() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    let additionalHeaderParameters: [String: Any] = ["key_attestation": "key_attestation_value"]

    let jws = try encoder.encode(payload, keyPair: mockKeyPair, additionalHeaderParameters: additionalHeaderParameters)

    let decoded = try JSONWebSignaturePlain(from: jws.rawJWS)
    let parameter: String? = decoded.header["key_attestation"]

    XCTAssertEqual(jws.payload, payload)
    XCTAssertEqual(parameter, "key_attestation_value")
  }

  func testEncode_withMultipleAdditionalHeaderParameter_merges() throws {
    let payload = RegisteredClaimsJWT.Mock.registeredClaims
    let additionalHeaderParameters: [String: Any] = [
      "key_attestation": "key_attestation_value",
      "foo": 1234,
    ]

    let jws = try encoder.encode(payload, using: mockKeyPair, additionalHeaderParameters: additionalHeaderParameters)

    let decoded = try JSONWebSignaturePlain(from: jws)
    let keyAttestation: String? = decoded.header["key_attestation"]
    let foo: Int? = decoded.header["foo"]

    XCTAssertEqual(keyAttestation, "key_attestation_value")
    XCTAssertEqual(foo, 1234)
  }

  // MARK: Private

  private var encoder = JWSEncoder()
  private let mockKeyPair = VaultKeyPair.Mock.ES256
}
