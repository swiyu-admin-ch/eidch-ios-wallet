import BITCore
import Foundation
import JOSESwift
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
    let keyManagementAlgorithm = try JOSESwift.KeyManagementAlgorithm(from: publicKey)
    let contentEncryptionAlgorithm = try ContentEncryptionAlgorithm(from: encryptionAlgorithm)

    let header = try createHeader(
      publicKey: publicKey,
      keyManagementAlgorithm: keyManagementAlgorithm,
      contentEncryptionAlgorithm: contentEncryptionAlgorithm,
      compressionAlgorithm: compressionAlgorithm)
    let encrypter = try createEncrypter(
      publicKey: publicKey,
      keyManagementAlgorithm: keyManagementAlgorithm,
      contentEncryptionAlgorithm: contentEncryptionAlgorithm)

    let jwe = try JWE(header: header, payload: Payload(data), encrypter: encrypter)

    return jwe.compactSerializedString
  }

  // MARK: Private

  private func createHeader(
    publicKey: JWK,
    keyManagementAlgorithm: JOSESwift.KeyManagementAlgorithm,
    contentEncryptionAlgorithm: ContentEncryptionAlgorithm,
    compressionAlgorithm: BITCrypto.CompressionAlgorithm?) throws
    -> JWEHeader
  {
    var header = JWEHeader(
      keyManagementAlgorithm: keyManagementAlgorithm,
      contentEncryptionAlgorithm: contentEncryptionAlgorithm)
    header.kid = publicKey.kid
    header.zip = compressionAlgorithm?.rawValue

    return header
  }

  private func createEncrypter(
    publicKey: JWK,
    keyManagementAlgorithm: JOSESwift.KeyManagementAlgorithm,
    contentEncryptionAlgorithm: ContentEncryptionAlgorithm) throws
    -> Encrypter
  {
    let encryptionKey = try ECPublicKey(publicKey)
    guard
      let encrypter = Encrypter(
        keyManagementAlgorithm: keyManagementAlgorithm,
        contentEncryptionAlgorithm: contentEncryptionAlgorithm,
        encryptionKey: encryptionKey)
    else {
      throw JWEEncrypterError.encrypterCreationFailed
    }

    return encrypter
  }
}
