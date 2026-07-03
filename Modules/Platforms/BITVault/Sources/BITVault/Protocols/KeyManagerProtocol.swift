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

  public func getKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query? = nil, options: VaultOptions? = nil) throws -> VaultKeyPair {
    let keyPair = try getKeyPair(withIdentifier: identifier, algorithm: algorithm, query: query)
    return VaultKeyPair(identifier: keyPair.identifier, privateKey: keyPair.privateKey, algorithm: keyPair.algorithm, options: options)
  }
}
