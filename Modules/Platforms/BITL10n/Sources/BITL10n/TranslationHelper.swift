import Foundation

final class TranslationHelper {

  // MARK: Internal

  static func localizeString(_ key: String, _ table: String, _ fallback: String) -> String {
    if UserDefaults.standard.bool(forKey: translationSwitchKey) {
      return key
    }

    var bundle: Bundle

    #if SWIFT_PACKAGE
    bundle = Bundle.module
    #else
    bundle = Bundle.main
    #endif

    return bundle.localizedString(forKey: key, value: fallback, table: table)
  }

  // MARK: Private

  private static let translationSwitchKey = "isTranslationSwitchEnabled"

}
