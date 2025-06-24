#if DEBUG
import BITCore
import Foundation
@testable import BITTestingCore

// MARK: CredentialDisplay.Mock

extension CredentialDisplay {
  public struct Mock {
    public static var sample = CredentialDisplay(name: "Some credential", locale: UserLocale.defaultLocaleIdentifier)
    public static var lightEnglish = CredentialDisplay(theme: "light", locale: "en")
    public static var darkEnglish = CredentialDisplay(theme: "dark", locale: "en")
    public static var arraySample: [CredentialDisplay] = [
      CredentialDisplay(name: "Test", locale: UserLocale.defaultLocaleIdentifier),
      CredentialDisplay(name: "Blob", backgroundColor: "#333333", locale: UserLocale.LocaleIdentifier.swissFrench.rawValue),
      CredentialDisplay(name: "Blob2", backgroundColor: "#333333", locale: UserLocale.LocaleIdentifier.swissGerman.rawValue),
    ]
  }
}
#endif
