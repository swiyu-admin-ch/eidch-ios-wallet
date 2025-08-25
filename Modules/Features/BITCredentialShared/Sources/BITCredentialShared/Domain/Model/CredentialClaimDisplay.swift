import BITCore
import BITEntities
import Foundation

public struct CredentialClaimDisplay: Codable, Hashable, Equatable, DisplayLocalizable {

  // MARK: Lifecycle

  public init(id: UUID = UUID(), locale: String? = nil, name: String? = nil, value: String? = nil) {
    self.id = id
    self.locale = locale
    self.name = name
    self.value = value
  }

  public init(_ entity: CredentialClaimDisplayEntity) {
    self.init(
      id: entity.id,
      locale: entity.locale,
      name: entity.name,
      value: entity.value)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    locale = try container.decode(String.self, forKey: .locale)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    value = try container.decodeIfPresent(String.self, forKey: .value)
  }

  // MARK: Public

  public var id: UUID
  public var locale: UserLocale?
  public var name: String?
  public var value: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case locale
    case name
    case value
  }

}
