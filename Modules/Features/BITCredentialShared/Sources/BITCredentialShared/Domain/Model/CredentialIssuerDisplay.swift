import BITCore
import BITCrypto
import BITEntities
import Foundation

// MARK: - CredentialIssuerDisplay

public struct CredentialIssuerDisplay: Codable, Equatable, DisplayLocalizable, Swift.Hashable, Sendable {

  // MARK: Lifecycle

  public init(id: UUID = UUID(), locale: String? = nil, name: String? = nil, image: Data?) {
    self.id = id
    self.locale = locale ?? UserLocale.defaultLocaleIdentifier
    self.name = name
    self.image = image
  }

  init(_ entity: CredentialIssuerDisplayEntity) {
    self.init(
      id: entity.id,
      locale: entity.locale,
      name: entity.name,
      image: entity.cachedImage)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    locale = try container.decodeIfPresent(String.self, forKey: .locale) ?? UserLocale.defaultLocaleIdentifier
    image = try container.decodeIfPresent(Data.self, forKey: .image)
  }

  // MARK: Public

  public var id: UUID
  public var name: String?
  public var locale: UserLocale?
  public var image: Data?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case image
    case locale
  }
}
