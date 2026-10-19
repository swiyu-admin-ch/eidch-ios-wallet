import Factory
import FactoryTesting
import Foundation
import Security
import Testing
@testable import BITCrypto
@testable import BITTestingCore

@Suite(.container)
struct JWEDecrypterTests {

  // MARK: Lifecycle

  init() {
    let aesDecrypter = DecryptableSpy()
    self.aesDecrypter = aesDecrypter

    let concatKeyDerivable = ConcatKeyDerivableSpy()
    self.concatKeyDerivable = concatKeyDerivable

    Container.shared.decrypter.register { aesDecrypter }
    Container.shared.concatKeyDerivable.register { concatKeyDerivable }

    decrypter = JWEDecrypter()
  }

  // MARK: Internal

  @Test
  func decrypt_uncompressed_returnsDecrypted() throws {
    let data = try decrypter.decrypt(payload: JWEMock.Mock.validSampleData, privateKey: privateKeyMock, limit: mockJWESizeLimit)

    let decoded = try JSONDecoder().decode(MockPayload.self, from: data)

    #expect(decoded == payloadMock)
  }

  @Test
  func decrypt_deflated_returnsDecryptedAndDecompressed() throws {
    let data = try decrypter.decrypt(payload: JWEMock.Mock.validDeflateSampleData, privateKey: privateKeyMock, limit: mockJWESizeLimit)

    let decoded = try JSONDecoder().decode(MockPayload.self, from: data)

    #expect(decoded == payloadMock)
  }

  @Test
  func decrypt_invalidPrivateKey_throws() throws {
    let rsaPrivateKey = SecKeyTestsHelper.createPrivateKey(type: kSecAttrKeyTypeRSA as String)

    #expect(throws: (any Error).self) {
      try decrypter.decrypt(payload: JWEMock.Mock.validSampleData, privateKey: rsaPrivateKey, limit: mockJWESizeLimit)
    }
  }

  @Test
  func decrypt_cipherTextLengthTooBig_throws() throws {
    let rsaPrivateKey = SecKeyTestsHelper.createPrivateKey(type: kSecAttrKeyTypeRSA as String)
    let payload = String(repeating: "x", count: mockJWESizeLimit.maxCompressedCipherTextLength + 1)

    #expect(throws: JWEDecrypterError.maxCompressedCipherTextLengthExceeded) {
      try decrypter.decrypt(payload: Data(payload.utf8), privateKey: rsaPrivateKey, limit: mockJWESizeLimit)
    }
  }

  @Test
  func decrypt_hardwareBoundedKey_success() throws {
    let expectedData = Data(UUID().uuidString.utf8)
    concatKeyDerivable.deriveKeySecretAlgorithmPartyUInfoPartyVInfoKeyByteCountReturnValue = Data(count: 32)
    aesDecrypter.decryptWithSymmetricKeyAdditionalAuthenticatedDataReturnValue = expectedData

    let data = try decrypter.decrypt(payload: JWEMock.Mock.validSampleData, privateKey: privateKeyMock, keyType: .hardware, limit: mockJWESizeLimit)

    #expect(data == expectedData)
    #expect(aesDecrypter.decryptWithSymmetricKeyAdditionalAuthenticatedDataCallsCount == 1)
    #expect(concatKeyDerivable.deriveKeySecretAlgorithmPartyUInfoPartyVInfoKeyByteCountCallsCount == 1)
  }

  // MARK: Private

  private struct MockPayload: Codable, Equatable {
    let key: String
  }

  private let payloadMock = MockPayload(key: "value")
  private let privateKeyMock = SecKeyTestsHelper.createStaticPrivateKey()
  private let mockJWESizeLimit = JWESizeLimit.Mock.sample

  private let decrypter: JWEDecrypter

  private let aesDecrypter: DecryptableSpy
  private let concatKeyDerivable: ConcatKeyDerivableSpy
}
