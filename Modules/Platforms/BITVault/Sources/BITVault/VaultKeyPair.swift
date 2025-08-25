import Foundation

public struct VaultKeyPair: Equatable {

  // MARK: Lifecycle

  public init(identifier: String, privateKey: SecKey, algorithm: VaultAlgorithm, options: VaultOptions? = nil) {
    self.identifier = identifier
    self.privateKey = privateKey
    self.algorithm = algorithm
    self.options = options
  }

  // MARK: Public

  public let identifier: String
  public let privateKey: SecKey
  public let algorithm: VaultAlgorithm
  public let options: VaultOptions?

  public var publicKey: SecKey? {
    SecKeyCopyPublicKey(privateKey)
  }
}
