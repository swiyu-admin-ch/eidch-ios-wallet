import Foundation

public struct KeyPair: Equatable {
  public let identifier: UUID
  public let privateKey: SecKey
  public let algorithm: String

  public var publicKey: SecKey? {
    SecKeyCopyPublicKey(privateKey)
  }

  public init(identifier: UUID, algorithm: String, privateKey: SecKey) {
    self.identifier = identifier
    self.algorithm = algorithm
    self.privateKey = privateKey
  }
}
