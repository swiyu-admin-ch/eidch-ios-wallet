#if DEBUG
import Foundation
@testable import BITCore

extension ClusterDisplay {
  public struct Mock {
    public static var defaultLocale = ClusterDisplay(locale: UserLocale.defaultLocaleIdentifier, name: "Default cluster display")
    public static var defaultLocaleOnly = [defaultLocale]
    public static var array = [
      defaultLocale,
      ClusterDisplay(locale: UserLocale.LocaleIdentifier.swissFrench.rawValue, name: "fr-CH Cluster display"),
      ClusterDisplay(locale: UserLocale.LocaleIdentifier.swissGerman.rawValue, name: "de-CH Cluster display"),
    ]
  }
}
#endif
