// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Foundation
import Security
import XCTest
@testable import BITCrypto
@testable import BITTestingCore

// MARK: - JWEDecrypterTests

class JWEDecrypterTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    decrypter = JWEDecrypter()
  }

  func testDecrypt_uncompressed_returnsDecrypted() throws {
    let data = try decrypter.decrypt(payload: JWEMock.Mock.validSampleData, privateKey: privateKeyMock)

    let decoded = try JSONDecoder().decode(MockPayload.self, from: data)

    XCTAssertEqual(decoded, payloadMock)
  }

  func testDecrypt_deflated_returnsDecryptedAndDecompressed() throws {
    let data = try decrypter.decrypt(payload: JWEMock.Mock.validDeflateSampleData, privateKey: privateKeyMock)

    let decoded = try JSONDecoder().decode(MockPayload.self, from: data)

    XCTAssertEqual(decoded, payloadMock)
  }

  func testDecrypt_invalidPrivateKey_throws() throws {
    let rsaPrivateKey = SecKeyTestsHelper.createPrivateKey(type: kSecAttrKeyTypeRSA as String)

    XCTAssertThrowsError(
      try decrypter.decrypt(
        payload: JWEMock.Mock.validSampleData,
        privateKey: rsaPrivateKey))
  }

  func testDecrypt_cipherTextLengthTooBig_throws() throws {
    let rsaPrivateKey = SecKeyTestsHelper.createPrivateKey(type: kSecAttrKeyTypeRSA as String)
    let payload = String(repeating: "x", count: 6_000_001)

    XCTAssertThrowsError(
      try decrypter.decrypt(
        payload: Data(payload.utf8),
        privateKey: rsaPrivateKey))
    { error in
      XCTAssertEqual(error as? JWEDecrypterError, .maxCompressedCipherTextLengthExceeded)
    }
  }

  // MARK: Private

  private struct MockPayload: Codable, Equatable {
    let key: String
  }

  private let payloadMock = MockPayload(key: "value")
  private let privateKeyMock = SecKeyTestsHelper.createStaticPrivateKey()

  private var decrypter = JWEDecrypter()
}
