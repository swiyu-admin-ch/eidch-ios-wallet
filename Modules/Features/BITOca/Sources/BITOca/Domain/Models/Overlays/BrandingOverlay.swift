// MARK: - BrandingOverlay

import BITCore
import Foundation
import RegexBuilder

// MARK: - BrandingOverlay1x1

public struct BrandingOverlay1x1: LocalizedOverlay {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    captureBaseDigest = try container.decode(String.self, forKey: .captureBaseDigest)
    logo = try container.decodeIfPresent(URL.self, forKey: .logo)
    backgroundImage = try container.decodeIfPresent(URL.self, forKey: .backgroundImage)
    backgroundImageSlice = try container.decodeIfPresent(String.self, forKey: .backgroundImageSlice)
    primaryBackgroundColor = try container.decodeIfPresent(String.self, forKey: .primaryBackgroundColor)
    secondaryBackgroundColor = try container.decodeIfPresent(String.self, forKey: .secondaryBackgroundColor)
    primaryAttribute = try container.decodeIfPresent(String.self, forKey: .primaryAttribute)
    secondaryAttribute = try container.decodeIfPresent(String.self, forKey: .secondaryAttribute)
    issuedDateAttribute = try container.decodeIfPresent(String.self, forKey: .issuedDateAttribute)
    expiryDateAttribute = try container.decodeIfPresent(String.self, forKey: .expiryDateAttribute)
    language = try container.decode(String.self, forKey: .language)
    theme = try container.decodeIfPresent(String.self, forKey: .theme)
    primaryField = try container.decodeIfPresent(String.self, forKey: .primaryField)
    secondaryField = try container.decodeIfPresent(String.self, forKey: .secondaryField)

    try validateURIs()
  }

  public init(
    captureBaseDigest: String,
    logo: URL? = nil,
    backgroundImage: URL? = nil,
    backgroundImageSlice: String? = nil,
    primaryBackgroundColor: String? = nil,
    secondaryBackgroundColor: String? = nil,
    primaryAttribute: String? = nil,
    secondaryAttribute: String? = nil,
    issuedDateAttribute: String? = nil,
    expiryDateAttribute: String? = nil,
    language: String,
    theme: String? = nil,
    primaryField: String? = nil,
    secondaryField: String? = nil) throws
  {
    self.captureBaseDigest = captureBaseDigest
    self.logo = logo
    self.backgroundImage = backgroundImage
    self.backgroundImageSlice = backgroundImageSlice
    self.primaryBackgroundColor = primaryBackgroundColor
    self.secondaryBackgroundColor = secondaryBackgroundColor
    self.primaryAttribute = primaryAttribute
    self.secondaryAttribute = secondaryAttribute
    self.issuedDateAttribute = issuedDateAttribute
    self.expiryDateAttribute = expiryDateAttribute
    self.language = language
    self.theme = theme
    self.primaryField = primaryField
    self.secondaryField = secondaryField

    try validateURIs()
  }

  // MARK: Public

  public let type = OverlaySpecType.branding1_1
  public let captureBaseDigest: String
  public let logo: URL?
  public let backgroundImage: URL?
  public let backgroundImageSlice: String?
  public let primaryBackgroundColor: String?
  public let secondaryBackgroundColor: String?
  public let primaryAttribute: String?
  public let secondaryAttribute: String?
  public let issuedDateAttribute: String?
  public let expiryDateAttribute: String?
  public let language: String
  public let theme: String?
  public var primaryField: String?
  public var secondaryField: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case language, logo, theme
    case captureBaseDigest = "capture_base"
    case backgroundImage = "background_image"
    case backgroundImageSlice = "background_image_slice"
    case primaryBackgroundColor = "primary_background_color"
    case secondaryBackgroundColor = "secondary_background_color"
    case primaryAttribute = "primary_attribute"
    case secondaryAttribute = "secondary_attribute"
    case issuedDateAttribute = "issued_date_attribute"
    case expiryDateAttribute = "expiry_date_attribute"
    case primaryField = "primary_field"
    case secondaryField = "secondary_field"
  }

  // MARK: Private

  private func validateURIs() throws {
    if let logo, !logo.isDataURL { throw OcaError.invalidOverlayDataURI }
    if let backgroundImage, !backgroundImage.isDataURL { throw OcaError.invalidOverlayDataURI }
  }
}

extension BrandingOverlay1x1 {

  // MARK: Internal

  func resolvePrimaryField(using attributeTransform: (String) -> String?) -> String? {
    resolveAttributeFieldTemplate(primaryField, using: attributeTransform)
  }

  func resolveSecondaryField(using attributeTransform: (String) -> String?) -> String? {
    resolveAttributeFieldTemplate(secondaryField, using: attributeTransform)
  }

  // MARK: Private

  private static let regex = Regex {
    "{{"
    Capture {
      ZeroOrMore(.any, .reluctant)
    }
    "}}"
  }

  /// Resolve name to ClaimsPathPointer "Fullname: {{firstname}} {{lastname}}" -> "Fullname: {{["firstname"]}} {{["lastname"]}}"
  private func resolveAttributeFieldTemplate(_ field: String?, using attributeTransform: (String) -> String?) -> String? {
    field.map {
      $0.replacing(Self.regex) { match in
        if let replacement = attributeTransform(String(match.1)) {
          "{{\(replacement)}}"
        } else {
          ""
        }
      }
    }
  }

}
