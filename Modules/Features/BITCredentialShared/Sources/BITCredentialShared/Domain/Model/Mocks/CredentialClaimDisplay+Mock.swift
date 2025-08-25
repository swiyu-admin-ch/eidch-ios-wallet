#if DEBUG
import BITCore
import Foundation
@testable import BITTestingCore

extension CredentialClaimDisplay {
  public struct Mock {
    public static var defaultLocale = CredentialClaimDisplay(locale: UserLocale.defaultLocaleIdentifier, name: "Default claim display")
    public static var defaultLocaleOnly = [defaultLocale]
    public static var array = [
      defaultLocale,
      CredentialClaimDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue, name: "fr-CH Claim display"),
      CredentialClaimDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue, name: "de-CH Claim display"),
    ]
  }
}
#endif
