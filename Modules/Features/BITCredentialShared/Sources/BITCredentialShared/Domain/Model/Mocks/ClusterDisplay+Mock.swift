#if DEBUG
import Foundation
@testable import BITCore

extension ClusterDisplay {
  public struct Mock {
    public static let defaultLocale = ClusterDisplay(locale: UserLocale.defaultLocaleIdentifier, name: "Default cluster display")
    public static let defaultLocaleOnly = [defaultLocale]
    public static let array = [
      defaultLocale,
      ClusterDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue, name: "fr-CH Cluster display"),
      ClusterDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue, name: "de-CH Cluster display"),
    ]
  }
}
#endif
