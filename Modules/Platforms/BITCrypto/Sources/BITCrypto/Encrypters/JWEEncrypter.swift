import BITCore
import Foundation
import JWSETKit
import Spyable

// MARK: - JWEEncrypterError

public enum JWEEncrypterError: Error {
  case encrypterCreationFailed
}

// MARK: - JWEEncrypterProtocol

@Spyable
public protocol JWEEncrypterProtocol {
  func encrypt(data: Data, publicKey: JWK, encryptionAlgorithm: EncryptionAlgorithm, compressionAlgorithm: BITCrypto.CompressionAlgorithm?) throws -> String
}

// MARK: - JWEEncrypter

public struct JWEEncrypter: JWEEncrypterProtocol {

  // MARK: Public

  public func encrypt(
    data: Data,
    publicKey: JWK,
    encryptionAlgorithm: EncryptionAlgorithm,
    compressionAlgorithm: BITCrypto.CompressionAlgorithm?) throws
    -> String
  {
    let keyManagementAlgorithm = try JSONWebKeyEncryptionAlgorithm(from: publicKey)
    let contentEncryptionAlgorithm = try JSONWebContentEncryptionAlgorithm(from: encryptionAlgorithm)
    guard let encryptionKey = try publicKey.jsonWebKey() as? JSONWebECPublicKey else {
      throw JWEEncrypterError.encrypterCreationFailed
    }

    let header = try createHeader(
      publicKey: publicKey,
      compressionAlgorithm: compressionAlgorithm)
    let jwe = try JSONWebEncryption(
      protected: header,
      content: data,
      keyEncryptingAlgorithm: keyManagementAlgorithm,
      keyEncryptionKey: encryptionKey,
      contentEncryptionAlgorithm: contentEncryptionAlgorithm)

    return try String(jwe)
  }

  // MARK: Private

  private func createHeader(
    publicKey: JWK,
    compressionAlgorithm: BITCrypto.CompressionAlgorithm?) throws
    -> JOSEHeader
  {
    var header = JOSEHeader()
    header.keyId = publicKey.kid
    header.compressionAlgorithm = compressionAlgorithm.map { JSONWebCompressionAlgorithm(rawValue: $0.rawValue) }

    return header
  }
}
