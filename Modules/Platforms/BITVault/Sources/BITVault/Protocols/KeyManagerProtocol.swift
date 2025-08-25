import Foundation
import Spyable

// MARK: - KeyManagerProtocol

@Spyable
public protocol KeyManagerProtocol {
  @discardableResult
  func generateKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm, options: VaultOptions, query: Query?) throws -> VaultKeyPair
  func getKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> VaultKeyPair
  func deleteKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm) throws
  func getExternalRepresentation(of privateKey: SecKey) throws -> (rawPublicKey: Data, rawPrivateKey: Data)
}

extension KeyManagerProtocol {

  public func getKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm) throws -> VaultKeyPair {
    try getKeyPair(withIdentifier: identifier, algorithm: algorithm, query: nil)
  }
}
