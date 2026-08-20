// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

import Foundation
import Security
import Testing
@testable import BITCrypto
@testable import BITTestingCore

// MARK: - JWETests

@Suite(.serialized)
struct JWETests {

  // MARK: Internal

  @Test
  func roundTrip_uncompressedA128GCM_returnsOriginalData() throws {
    let originalData = Data("{\"key\": \"value\"}".utf8)

    let data = try encryptAndDecrypt(data: originalData, encryptionAlgorithm: .A128GCM)

    #expect(data == originalData)
  }

  @Test
  func roundTrip_deflateCompressedA128GCM_returnsOriginalData() throws {
    let originalData = Data("{\"key\": \"value\"}".utf8)

    let data = try encryptAndDecrypt(data: originalData, encryptionAlgorithm: .A128GCM, compressionAlgorithm: .deflate)

    #expect(data == originalData)
  }

  @Test
  func roundTrip_uncompressedA256GCM_returnsOriginalData() throws {
    let originalData = Data("{\"key\": \"value\"}".utf8)

    let data = try encryptAndDecrypt(data: originalData, encryptionAlgorithm: .A256GCM)

    #expect(data == originalData)
  }

  @Test
  func roundTrip_deflateCompressedA256GCM_returnsOriginalData() throws {
    let originalData = Data("{\"key\": \"value\"}".utf8)

    let data = try encryptAndDecrypt(data: originalData, encryptionAlgorithm: .A256GCM, compressionAlgorithm: .deflate)

    #expect(data == originalData)
  }

  @Test
  func roundTrip_deflateCompressedAtLimit_returnsOriginalData() throws {
    let originalData = Data(repeating: 0x4F, count: 20 * 1024 * 1024)

    let data = try encryptAndDecrypt(data: originalData, encryptionAlgorithm: .A256GCM, compressionAlgorithm: .deflate)

    #expect(data == originalData)
  }

  @Test
  func roundTrip_deflateCompressedTooBig_throwsError() throws {
    let originalData = Data(repeating: 0x4F, count: 20 * 1024 * 1024 + 1)

    #expect(throws: JWEDecrypterError.maxDecompressedSizeExceeded) {
      _ = try encryptAndDecrypt(data: originalData, encryptionAlgorithm: .A256GCM, compressionAlgorithm: .deflate)
    }
  }

  // MARK: Private

  private static let privateKeyMock = SecKeyTestsHelper.createStaticPrivateKey()

  private let jwkMock = JWK(
    kty: "EC",
    kid: nil,
    crv: "P-256",
    x: "qMLlOR5XV8-CWSCN9S3HQOfPmYMhkZxK1FJObikzYe8",
    y: "vmN1-2KgPIAV3VuraXZhAuhr6rr27HL3mPLSaTo-Hdc",
    alg: "ECDH-ES")

  private var decrypter: JWEDecrypter {
    JWEDecrypter()
  }

  private var encrypter: JWEEncrypter {
    JWEEncrypter()
  }

  private func encryptAndDecrypt(
    data: Data,
    encryptionAlgorithm: EncryptionAlgorithm,
    compressionAlgorithm: CompressionAlgorithm? = nil) throws
    -> Data
  {
    let encryptedData = try encrypter.encrypt(
      data: data,
      publicKey: jwkMock,
      encryptionAlgorithm: encryptionAlgorithm,
      compressionAlgorithm: compressionAlgorithm)
    return try decrypter.decrypt(payload: Data(encryptedData.utf8), privateKey: Self.privateKeyMock)
  }
}
