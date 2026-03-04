import Foundation

// MARK: - AppDelegate + EnvironmentAutoRegistering

extension AppDelegate: EnvironmentAutoRegistering {
}

// MARK: - EnvironmentAutoRegistering

protocol EnvironmentAutoRegistering {
  func registerEnvironmentValues()
}

extension EnvironmentAutoRegistering {
  func registerEnvironmentValues() {
    // Use this function to override any registered values per environment
    // For example:
    // ```
    // #if DEV
    // Container.shared.versionEnforcementUrl.register {
    //   URL(string: "https://custom.enforcement.url")!
    // }
    // #endif
    // ``
  }
}
