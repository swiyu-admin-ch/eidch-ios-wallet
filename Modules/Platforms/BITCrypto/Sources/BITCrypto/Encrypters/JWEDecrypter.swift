import Foundation
import JOSESwift
import Security
import Spyable

// MARK: - JWEDecrypterError

public enum JWEDecrypterError: Error {
  case decrypterCreationFailed
}

// MARK: - JWEDecrypterProtocol

@Spyable
public protocol JWEDecrypterProtocol {
  func decrypt(payload: Data, privateKey: SecKey) throws -> Data
}

// MARK: - JWEDecrypter

public struct JWEDecrypter: JWEDecrypterProtocol {

  public func decrypt(payload: Data, privateKey: SecKey) throws -> Data {
    let jwe = try JWE(compactSerialization: payload)
    let keyPair = try ECKeyPair(privateKey: privateKey)

    guard
      let keyManagementAlgorithm = jwe.header.keyManagementAlgorithm,
      let contentEncryptionAlgorithm = jwe.header.contentEncryptionAlgorithm,
      let decrypter = Decrypter(
        keyManagementAlgorithm: keyManagementAlgorithm,
        contentEncryptionAlgorithm: contentEncryptionAlgorithm,
        decryptionKey: keyPair)
    else {
      throw JWEDecrypterError.decrypterCreationFailed
    }

    return try jwe.decrypt(using: decrypter).data()
  }
}
