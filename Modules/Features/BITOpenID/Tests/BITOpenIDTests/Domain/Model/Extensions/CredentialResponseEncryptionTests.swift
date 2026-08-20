// swiftlint:disable force_try
import XCTest
@testable import BITCrypto
@testable import BITOpenID
@testable import BITVault

class CredentialResponseEncryptionTests: XCTestCase {

  // MARK: Internal

  func testInit_success() {
    let contextMock = Self.createEnrcyptionContext()
    let responseEnryption = try? CredentialResponseEncryption(from: contextMock)
    XCTAssertEqual(responseEnryption?.jwk, responseJWKMock)
    XCTAssertEqual(responseEnryption?.enc, contextMock.credentialResponseEncryptionAlgorithm.rawValue)
    XCTAssertEqual(responseEnryption?.zip, contextMock.credentialResponseEncryptionZipValue?.rawValue)
  }

  // MARK: Private

  private let responseJWKMock: JWK = {
    let vaultKeyPair = VaultKeyPair.Mock.ES256
    return try! JWK(from: vaultKeyPair)
  }()

  private static func createEnrcyptionContext(
    responseKeyPair: VaultKeyPair = VaultKeyPair.Mock.ES256,
    responseEnrcryptionAlgorithm: EncryptionAlgorithm = .A128GCM)
    -> CredentialEncryptionContext
  {
    CredentialEncryptionContext(
      issuerPublicKey: JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue),
      credentialRequestEncryptionAlgorithm: .A128GCM,
      credentialRequestEncryptionZipValue: .deflate,
      responseKeyPair: responseKeyPair,
      credentialResponseEncryptionAlgorithm: responseEnrcryptionAlgorithm,
      credentialResponseEncryptionZipValue: .deflate)

  }
}
