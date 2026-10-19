import Foundation

public typealias UserLocale = String
public typealias UserLanguageCode = String

// MARK: - UserLocale.LocaleIdentifier

extension UserLocale {

  public enum LocaleIdentifier: String, CaseIterable {
    case swissGerman = "de-CH"
    case swissFrench = "fr-CH"
    case swissItalian = "it-CH"
    case english = "en"
    case romansh = "rm"
  }

  public static let defaultLocaleIdentifier: UserLocale = LocaleIdentifier.english.rawValue

}

extension UserLanguageCode {

  public enum LanguageIdentifier: String {
    case german = "de"
    case french = "fr"
    case italian = "it"
    case english = "en"
  }

  public static let defaultAppLanguageCode: UserLanguageCode = LanguageIdentifier.english.rawValue

}
