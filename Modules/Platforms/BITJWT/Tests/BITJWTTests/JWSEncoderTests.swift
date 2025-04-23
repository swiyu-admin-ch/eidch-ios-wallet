import Foundation
import JOSESwift
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITTestingCore

// MARK: - JWSEncoderTests

final class JWSEncoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    mockKeyPair = KeyPair(identifier: mockKeyIdentifier, algorithm: "ES512", privateKey: mockPrivateKey)
    encoder = JWSEncoder()
  }

  func testEncode_EncodePayloadAndDecode_PayloadAndHeaderFieldsMatch() throws {
    let payload = JWTRegisteredPayload.Mock.registeredPayload

    let jws = try encoder.encode(payload, using: mockKeyPair)

    let decoded = try JWSDecoder().decode(JWTRegisteredPayload.self, from: jws)
    XCTAssertEqual(decoded.payload, payload)
    XCTAssertEqual(decoded.header.algorithm.rawValue, mockKeyPair.algorithm)
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
    let payload = JWTRegisteredPayload.Mock.registeredPayload
    encoder.keyEncodingStrategy = .none

    let jws = try encoder.encode(payload, using: mockKeyPair)

    let decoded = try JWSDecoder().decode(JWTRegisteredPayload.self, from: jws)
    XCTAssertEqual(decoded.payload, payload)
    XCTAssertEqual(decoded.header.algorithm.rawValue, mockKeyPair.algorithm)
    XCTAssertNil(decoded.header.keyIdentifier)
    XCTAssertEqual(decoded.header.type, payload.type)
    XCTAssertNil(decoded.header.jwk)
  }

  func testEncode_EncodePayloadAndDecodeIsoDateEncodingStrategy_PayloadAndHeaderFieldsMatch() throws {
    let payload = JWTRegisteredPayload.Mock.registeredPayload
    encoder.keyEncodingStrategy = .none
    encoder.dateEncodingStrategy = .iso8601
    let decoder = JWSDecoder(dateDecodingStrategy: .iso8601)

    let jws = try encoder.encode(payload, using: mockKeyPair)

    let decoded = try decoder.decode(JWTRegisteredPayload.self, from: jws)
    XCTAssertEqual(decoded.payload, payload)
    XCTAssertEqual(decoded.header.algorithm.rawValue, mockKeyPair.algorithm)
    XCTAssertNil(decoded.header.keyIdentifier)
    XCTAssertEqual(decoded.header.type, payload.type)
    XCTAssertNil(decoded.header.jwk)
  }

  func testEncode_InvalidAlgorithm_ThrowsError() throws {
    let payload = JWTRegisteredPayload.Mock.registeredPayload
    mockKeyPair = KeyPair(identifier: mockKeyIdentifier, algorithm: "invalid", privateKey: mockPrivateKey)

    XCTAssertThrowsError(try encoder.encode(payload, using: mockKeyPair)) { error in
      XCTAssertEqual(error as? JWSEncoderError, .algorithmNotFound)
    }
  }

  func testEncode_JwkCannotBeCreated_ThrowsError() throws {
    let payload = JWTRegisteredPayload.Mock.registeredPayload
    let privateKey = SecKeyTestsHelper.createPrivateKey(type: kSecAttrKeyTypeRSA as String)
    mockKeyPair = KeyPair(identifier: mockKeyIdentifier, algorithm: "ES512", privateKey: privateKey)

    XCTAssertThrowsError(try encoder.encode(payload, using: mockKeyPair)) { error in
      XCTAssertEqual(error as? JWSEncoderError, .cannotCreateJwk)
    }
  }

  // MARK: Private

  private var encoder = JWSEncoder()
  private let mockPrivateKey: SecKey = SecKeyTestsHelper.createPrivateKey()
  // swiftlint:disable all
  private let mockKeyIdentifier = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
  private var mockKeyPair: KeyPair!
  // swiftlint:enable all

}
