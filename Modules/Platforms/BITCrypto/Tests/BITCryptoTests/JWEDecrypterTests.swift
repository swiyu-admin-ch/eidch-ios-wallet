// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Foundation
import JOSESwift
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

  func testDecrypt_success() throws {
    let data = try decrypter.decrypt(
      payload: JWE.Mock.validSampleData,
      privateKey: privateKeyMock)

    let decoded = try JSONDecoder().decode(MockPayload.self, from: data)

    XCTAssertEqual(decoded, payloadMock)
  }

  func testDecrypt_invalidPrivateKey_throws() throws {
    let rsaPrivateKey = SecKeyTestsHelper.createPrivateKey(type: kSecAttrKeyTypeRSA as String)

    XCTAssertThrowsError(
      try decrypter.decrypt(
        payload: JWE.Mock.validSampleData,
        privateKey: rsaPrivateKey))
  }

  // MARK: Private

  private struct MockPayload: Codable, Equatable {
    let key: String
  }

  private let payloadMock = MockPayload(key: "value")
  private let privateKeyMock = SecKeyTestsHelper.createStaticPrivateKey()

  private var decrypter = JWEDecrypter()
}
