import BITCrypto
import BITEntities
import Foundation

public struct KeyBinding: Codable, Equatable, Swift.Hashable, Sendable {

  // MARK: Lifecycle

  public init(
    id: UUID,
    algorithm: String,
    bindingType: KeyType,
    publicKey: Data? = nil,
    privateKey: Data? = nil)
  {
    self.id = id
    self.algorithm = algorithm
    self.bindingType = bindingType
    self.publicKey = publicKey
    self.privateKey = privateKey
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    algorithm = try container.decode(String.self, forKey: .algorithm)
    bindingType = try container.decode(KeyType.self, forKey: .bindingType)
    publicKey = try container.decodeIfPresent(Data.self, forKey: .publicKey)
    privateKey = try container.decodeIfPresent(Data.self, forKey: .privateKey)
  }

  init(_ entity: CredentialKeyBindingEntity) {
    self.init(
      id: entity.id,
      algorithm: entity.algorithm,
      bindingType: entity.publicKey == nil ? .hardware : .software,
      publicKey: entity.publicKey,
      privateKey: entity.privateKey)
  }

  init(_ entity: DPoPBindingEntity) {
    self.init(
      id: entity.id,
      algorithm: entity.algorithm,
      bindingType: KeyType(rawValue: entity.bindingType) ?? .software,
      publicKey: entity.publicKey,
      privateKey: entity.privateKey)
  }

  // MARK: Public

  public let id: UUID
  public let algorithm: String
  public let bindingType: KeyType
  public let publicKey: Data?
  public let privateKey: Data?
}
