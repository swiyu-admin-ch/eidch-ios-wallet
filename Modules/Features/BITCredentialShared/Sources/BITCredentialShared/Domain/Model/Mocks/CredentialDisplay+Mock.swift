#if DEBUG
import Foundation
@testable import BITCore

// MARK: CredentialDisplay.Mock

extension CredentialDisplay {
  public struct Mock {
    public static let sample = CredentialDisplay(name: "Some credential", locale: UserLocale.defaultLocaleIdentifier)
    public static let lightEnglish = CredentialDisplay(theme: "light", locale: "en")
    public static let darkEnglish = CredentialDisplay(theme: "dark", locale: "en")
    public static let arraySample: [CredentialDisplay] = [
      CredentialDisplay(name: "Test", locale: UserLocale.defaultLocaleIdentifier),
      CredentialDisplay(name: "Blob", backgroundColor: "#333333", locale: UserLocale.LocaleIdentifier.swissFrench.rawValue),
      CredentialDisplay(name: "Blob2", backgroundColor: "#333333", locale: UserLocale.LocaleIdentifier.swissGerman.rawValue),
    ]
  }
}
#endif
