import CryptoKit
import Foundation
import Spyable

// MARK: - Encryptable

/// A protocol for secure encryption and decryption of data, designed to provide confidentiality through symmetric encryption algorithms.
@Spyable
public protocol Encryptable {

  /// Produce a cipher of the data given in parameter.
  /// For an asymmetric key, a derivation must be made considering the algorithm given in parameter.
  /// This is because encryption are working with symmetric keys.
  /// - Parameters:
  ///   - data: The data to to encrypt
  ///   - privateKey: The asymmetricKey to be derived for the encryption
  ///   - length: Length In bytes
  ///   - derivationAlgorithm: The derivation algorithm to be used for the asymmetric key given in parameter
  ///   - initialVector: initialVector to take in consideration for the encryption. Can be nil.
  ///   - Returns: The cipher of the input data
  func encrypt(
    _ data: Data,
    withAsymmetricKey privateKey: SecKey,
    length: Int,
    derivationAlgorithm: SecKeyAlgorithm,
    initialVector: Data?) throws
    -> Data

  /// Produce a cipher of the data given in parameter.
  /// - Parameters:
  ///   - data: The data to to encrypt
  ///   - Returns: The cipher of the input data
  func encrypt(
    _ data: Data,
    withSymmetricKey key: SymmetricKeyProtocol,
    initialVector: Data?) throws
    -> Data

}

// MARK: - EncrypterError

enum EncrypterError: Error {
  case cannotRetrievePublicKey
  case cannotCopyKeyExchangeResult(errorDerive: Unmanaged<CFError>?)
  case cannotDeriveKey
  case unexpectedSymmetricKey
  case cannotSeal
}

// MARK: - AESEncrypter

struct AESEncrypter: Encryptable {

  func encrypt(
    _ data: Data,
    withAsymmetricKey privateKey: SecKey,
    length: Int,
    derivationAlgorithm: SecKeyAlgorithm,
    initialVector: Data?) throws
    -> Data
  {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw EncrypterError.cannotRetrievePublicKey
    }
    guard
      let derivedKey = try SymmetricKeyUtils.deriveKeyPair(
        from: privateKey,
        and: publicKey,
        using: derivationAlgorithm,
        length: length) as? SymmetricKey else
    {
      throw EncrypterError.cannotDeriveKey
    }

    return try encrypt(data, withSymmetricKey: derivedKey, initialVector: initialVector)
  }

  func encrypt(
    _ data: Data,
    withSymmetricKey key: SymmetricKeyProtocol,
    initialVector: Data?) throws
    -> Data
  {
    let nonce = Self.createNonce(considering: initialVector)
    guard let symmetricKey = key as? SymmetricKey else {
      throw EncrypterError.unexpectedSymmetricKey
    }

    guard let encryptedData = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce).combined else {
      throw EncrypterError.cannotSeal
    }

    return encryptedData
  }
}

extension AESEncrypter {

  private static func createNonce(considering initialVector: Data?) -> AES.GCM.Nonce {
    (try? initialVector.map { try AES.GCM.Nonce(data: $0) }) ?? AES.GCM.Nonce()
  }

}
