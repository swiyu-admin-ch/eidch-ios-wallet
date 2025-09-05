import SwiftUI

// MARK: - SettingsViewModel

class SettingsViewModel: ObservableObject {

  @Published var currentLanguage = String()

  func openLanguage() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  func getCurrentLanguage() {
    guard
      let currentLanguageCode = Locale.current.language.languageCode?.identifier,
      let language = Locale(identifier: currentLanguageCode).localizedString(forLanguageCode: currentLanguageCode)
    else {
      currentLanguage = ""
      return
    }
    currentLanguage = language
  }
}
