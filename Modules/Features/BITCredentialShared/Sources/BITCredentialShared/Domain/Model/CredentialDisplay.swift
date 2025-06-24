import BITCore
import BITEntities
import Foundation

// MARK: - CredentialDisplay

public struct CredentialDisplay: Codable, Identifiable, DisplayLocalizable {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    name: String? = nil,
    backgroundColor: String? = nil,
    theme: String? = nil,
    locale: UserLocale,
    logoAltText: String? = nil,
    logoBase64: Data? = nil,
    summary: String? = nil,
    credentialId: UUID? = nil)
  {
    self.id = id
    self.name = name
    self.backgroundColor = backgroundColor
    self.theme = theme
    self.locale = locale
    self.logoAltText = logoAltText
    self.logoBase64 = logoBase64
    self.summary = summary
    self.credentialId = credentialId
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
    theme = try container.decodeIfPresent(String.self, forKey: .theme)
    locale = try container.decodeIfPresent(String.self, forKey: .locale) ?? UserLocale.defaultLocaleIdentifier
    logoAltText = try container.decodeIfPresent(String.self, forKey: .logoAltText)
    logoBase64 = try container.decodeIfPresent(Data.self, forKey: .logoBase64)
    summary = try container.decodeIfPresent(String.self, forKey: .summary)
    credentialId = try container.decodeIfPresent(UUID.self, forKey: .credentialId)
  }

  init(_ entity: CredentialDisplayEntity) {
    self.init(
      id: entity.id,
      name: entity.name,
      backgroundColor: entity.backgroundColor,
      theme: entity.theme,
      locale: entity.locale ?? UserLocale.defaultLocaleIdentifier,
      logoAltText: entity.logoAltText,
      logoBase64: entity.logoData,
      summary: entity.summary,
      credentialId: entity.credential.first?.id)
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case id
    case name
    case backgroundColor = "background_color"
    case theme
    case locale
    case logoAltText = "logo_alt_text"
    case logoBase64 = "logo_data"
    case summary
    case credentialId = "credential_id"
  }

  public var id: UUID
  public var name: String?
  public var backgroundColor: String?
  public var theme: String?
  public var locale: UserLocale?
  public var logoAltText: String?
  public var logoBase64: Data?
  public var summary: String?
  public var credentialId: UUID?
}

// MARK: Equatable

extension CredentialDisplay: Equatable {

  public static func == (lhs: CredentialDisplay, rhs: CredentialDisplay) -> Bool {
    lhs.id == rhs.id &&
      lhs.name == rhs.name &&
      lhs.backgroundColor == rhs.backgroundColor &&
      lhs.theme == rhs.theme &&
      lhs.locale == rhs.locale &&
      lhs.logoAltText == rhs.logoAltText &&
      lhs.logoBase64 == rhs.logoBase64 &&
      lhs.summary == rhs.summary &&
      lhs.credentialId == rhs.credentialId
  }

}
