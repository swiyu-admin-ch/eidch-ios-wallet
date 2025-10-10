import SwiftUI

// MARK: - SettingsViewModel

class SettingsViewModel: ObservableObject {

  func openLanguage() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }
}
