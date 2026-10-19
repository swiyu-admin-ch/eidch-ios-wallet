#if DEBUG
import Foundation
@testable import BITCore

extension CredentialClaimDisplay {
  public struct Mock {
    public static let defaultLocale = CredentialClaimDisplay(locale: UserLocale.defaultLocaleIdentifier, name: "Default claim display")
    public static let defaultLocaleOnly = [defaultLocale]
    public static let array = [
      defaultLocale,
      CredentialClaimDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue, name: "fr-CH Claim display"),
      CredentialClaimDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue, name: "de-CH Claim display"),
    ]
  }
}
#endif
