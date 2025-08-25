import Foundation

// MARK: - EncryptionManager

public struct EncryptionManager: EncryptionManagerProtocol {

  // MARK: Lifecycle

  public init(keyManager: KeyManagerProtocol = KeyManager()) {
    self.keyManager = keyManager
  }

  // MARK: Public

  public func encrypt(data: Data, withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> Data {
    let keyPair = try keyManager.getKeyPair(withIdentifier: identifier, algorithm: algorithm, query: query)
    guard let publicKey = keyPair.publicKey else {
      throw VaultError.publicKeyRetrievalError
    }

    if !SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm.encryptionAlgorithm) {
      throw VaultError.algorithmNotSupported
    }

    var error: Unmanaged<CFError>?
    guard let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm.encryptionAlgorithm, data as CFData, &error) else {
      let errorDescription = (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "Unknown error"
      throw VaultError.encryptionError(errorDescription)
    }

    return encryptedData as Data
  }

  public func decrypt(data: Data, withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> Data {
    let keyPair = try keyManager.getKeyPair(withIdentifier: identifier, algorithm: algorithm, query: query)

    if !SecKeyIsAlgorithmSupported(keyPair.privateKey, .decrypt, algorithm.encryptionAlgorithm) {
      throw VaultError.algorithmNotSupported
    }

    var error: Unmanaged<CFError>?
    guard let decryptedData = SecKeyCreateDecryptedData(keyPair.privateKey, algorithm.encryptionAlgorithm, data as CFData, &error) else {
      let errorDescription = (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "Unknown error"
      throw VaultError.decryptionError(errorDescription)
    }

    return decryptedData as Data
  }

  // MARK: Private

  private let keyManager: KeyManagerProtocol

}
