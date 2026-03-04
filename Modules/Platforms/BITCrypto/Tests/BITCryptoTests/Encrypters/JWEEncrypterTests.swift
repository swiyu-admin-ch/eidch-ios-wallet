import Foundation
import JOSESwift
import XCTest
@testable import BITCrypto

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

    let jwe = try JWE(compactSerialization: jweString)

    XCTAssertEqual(jwe.header.keyManagementAlgorithm, KeyManagementAlgorithm.ECDH_ES)
    XCTAssertEqual(jwe.header.contentEncryptionAlgorithm, ContentEncryptionAlgorithm.A128GCM)
    XCTAssertEqual(jwe.header.kid, publicKeyMock.kid)
    XCTAssertEqual(jwe.header.zip, CompressionAlgorithm.deflate.rawValue)
    XCTAssertFalse(jwe.compactSerializedString.isEmpty)
  }

  func testEncrypt_invalidPublicKeyMock_throws() throws {
    let data = try JSONEncoder().encode(payload)
    XCTAssertThrowsError(try encrypter.encrypt(
      data: data,
      publicKey: invalidPublicKeyMock,
      encryptionAlgorithm: .A128GCM,
      compressionAlgorithm: nil))
    { error in
      XCTAssertEqual(error as? JOSESwift.KeyManagementAlgorithm.KeyManagementAlgorithmError, .notFound)
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
