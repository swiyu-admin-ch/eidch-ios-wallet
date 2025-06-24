import BITCore
import BITEntities
import Foundation

public struct ClusterDisplay: Codable, Hashable, Equatable, DisplayLocalizable {

  // MARK: Lifecycle

  public init(id: UUID = UUID(), locale: String, name: String) {
    self.id = id
    self.locale = locale
    self.name = name
  }

  public init(_ entity: CredentialClaimClusterDisplayEntity) {
    id = entity.id
    locale = entity.locale
    name = entity.name
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    locale = try container.decode(String.self, forKey: .locale)
    name = try container.decode(String.self, forKey: .name)
  }

  // MARK: Public

  public var id: UUID
  public var locale: UserLocale?
  public var name: String

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case locale
    case name
  }
}
