import BITEntities
import Foundation

// MARK: - KeyBinding

public struct KeyBinding: Codable, Equatable, Hashable {

  // MARK: Lifecycle

  public init(
    id: UUID,
    algorithm: String,
    bindingType: KeyBindingType,
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
    bindingType = try container.decode(KeyBinding.KeyBindingType.self, forKey: .bindingType)
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
      bindingType: KeyBindingType(rawValue: entity.bindingType) ?? .software,
      publicKey: entity.publicKey,
      privateKey: entity.privateKey)
  }

  // MARK: Public

  public enum KeyBindingType: String, Codable {
    case software
    case hardware
  }

  public let id: UUID
  public let algorithm: String
  public let bindingType: KeyBindingType
  public let publicKey: Data?
  public let privateKey: Data?
}
