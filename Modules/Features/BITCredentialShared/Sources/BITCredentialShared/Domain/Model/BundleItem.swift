import BITAnyCredentialFormat
import BITEntities
import Foundation

public struct BundleItem: Codable, Equatable, Hashable, Identifiable {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    payload: CredentialPayload,
    status: CredentialStatus = .unknown,
    presented: Bool = false,
    keyBinding: KeyBinding? = nil)
  {
    self.id = id
    self.payload = payload
    self.status = status
    self.presented = presented
    self.keyBinding = keyBinding
  }

  init(_ entity: BundleItemEntity) {
    self.init(
      id: entity.id,
      payload: entity.payload,
      status: CredentialStatus(entity.status),
      presented: entity.presented,
      keyBinding: entity.keyBinding.flatMap(KeyBinding.init))
  }

  // MARK: Public

  public let id: UUID
  public var payload: CredentialPayload
  public var status: CredentialStatus
  public var presented: Bool
  public var keyBinding: KeyBinding?
}
