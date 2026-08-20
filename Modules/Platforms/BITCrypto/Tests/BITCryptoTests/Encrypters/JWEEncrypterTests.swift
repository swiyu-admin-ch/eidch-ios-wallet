import Foundation
import JWSETKit
import XCTest
@testable import BITCrypto
@testable import BITTestingCore

// MARK: - JWEEncrypterTests

final class JWEEncrypterTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    encrypter = JWEEncrypter()
  }

  func testEncrypt_success() throws {
    let data = try JSONEncoder().encode(payload)
    let jweString = try encrypter.encrypt(
      data: data,
      publicKey: publicKeyMock,
      encryptionAlgorithm: .A128GCM,
      compressionAlgorithm: .deflate)

    let jwe = try JSONWebEncryption(from: jweString)

    XCTAssertEqual(jwe.header.protected.algorithm?.rawValue, KeyManagementAlgorithm.ECDH_ES.rawValue)
    XCTAssertEqual(jwe.header.protected.encryptionAlgorithm, .aesEncryptionGCM128)
    XCTAssertEqual(jwe.header.protected.keyId, publicKeyMock.kid)
    XCTAssertEqual(jwe.header.protected.compressionAlgorithm, .deflate)
    XCTAssertFalse(jwe.description.isEmpty)
  }

  func testEncrypt_invalidPublicKeyMock_throws() throws {
    let data = try JSONEncoder().encode(payload)
    XCTAssertThrowsError(try encrypter.encrypt(
      data: data,
      publicKey: invalidPublicKeyMock,
      encryptionAlgorithm: .A128GCM,
      compressionAlgorithm: nil))
    { error in
      XCTAssertEqual(error as? JSONWebKeyEncryptionAlgorithm.KeyManagementAlgorithmError, .notFound)
    }
  }

  // MARK: Private

  private struct MockPayload: Codable, Equatable {
    let value: String
  }

  private let payload = MockPayload(value: "value")
  private let invalidPublicKeyMock = JWK.Mock.invalidSample
  private lazy var publicKeyMock = JWK(
    kty: JWK.Mock.validSample.kty,
    kid: "kid",
    crv: JWK.Mock.validSample.crv,
    x: JWK.Mock.validSample.x,
    y: JWK.Mock.validSample.y,
    alg: "ECDH-ES")

  private var encrypter = JWEEncrypter()
}
