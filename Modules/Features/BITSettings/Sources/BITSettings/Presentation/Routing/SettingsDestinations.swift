import NavigatorUI
import SwiftUI

// MARK: - SettingsDestinations

public enum SettingsDestinations: NavigationDestination {
  case settings

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .settings:
      .managedSheet
    }
  }

  public var body: some View {
    SettingsDestinationView(destination: self)
  }
}

// MARK: - SettingsDestinationView

private struct SettingsDestinationView: View {
  let destination: SettingsDestinations

  var body: some View {
    switch destination {
    case .settings:
      SettingsView()
    }
  }
}
