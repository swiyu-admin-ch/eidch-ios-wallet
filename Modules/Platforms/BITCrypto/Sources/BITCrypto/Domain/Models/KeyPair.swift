import Foundation

public struct KeyPair: Equatable {

  // MARK: Lifecycle

  public init(identifier: UUID = UUID(), algorithm: String = "ES256", privateKey: SecKey) {
    self.identifier = identifier
    self.algorithm = algorithm
    self.privateKey = privateKey
  }

  // MARK: Public

  public let identifier: UUID
  public let privateKey: SecKey
  public let algorithm: String

  public var publicKey: SecKey? {
    SecKeyCopyPublicKey(privateKey)
  }
}
