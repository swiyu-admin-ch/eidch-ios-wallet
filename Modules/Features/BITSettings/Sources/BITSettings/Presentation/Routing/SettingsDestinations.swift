import BITAppAuth
import NavigatorUI
import SwiftUI

// MARK: - SettingsDestinations

public enum SettingsDestinations: Hashable {
  case settings
  case security
  case accessibility
  case licenses
  case imprint
  case lottie
  case changePassword(any ChangePinCodeDelegate)
  case biometrics(any BiometricChangeDelegate)
  case diagnosticData
  case activityHistory
  case licenseDetail(PackageDependency)

  // MARK: Public

  public nonisolated static func == (lhs: SettingsDestinations, rhs: SettingsDestinations) -> Bool {
    switch (lhs, rhs) {
    case (.accessibility, .accessibility),
         (.activityHistory, .activityHistory),
         (.diagnosticData, .diagnosticData),
         (.imprint, .imprint),
         (.licenses, .licenses),
         (.lottie, .lottie),
         (.security, .security),
         (.settings, .settings):
      true
    case (.changePassword(let lhsDelegate), .changePassword(let rhsDelegate)):
      lhsDelegate === rhsDelegate
    case (.biometrics(let lhsDelegate), .biometrics(let rhsDelegate)):
      lhsDelegate === rhsDelegate
    case (.licenseDetail(let lhsPackage), .licenseDetail(let rhsPackage)):
      lhsPackage == rhsPackage
    default:
      false
    }
  }

  public nonisolated func hash(into hasher: inout Hasher) {
    switch self {
    case .settings:
      hasher.combine("settings")
    case .security:
      hasher.combine("security")
    case .accessibility:
      hasher.combine("accessibility")
    case .licenses:
      hasher.combine("licenses")
    case .imprint:
      hasher.combine("imprint")
    case .lottie:
      hasher.combine("lottie")
    case .changePassword(let delegate):
      hasher.combine("password")
      hasher.combine(ObjectIdentifier(delegate))
    case .biometrics(let delegate):
      hasher.combine("biometrics")
      hasher.combine(ObjectIdentifier(delegate))
    case .diagnosticData:
      hasher.combine("diagnosticData")
    case .activityHistory:
      hasher.combine("activityHistory")
    case .licenseDetail(let package):
      hasher.combine("licenseDetail")
      hasher.combine(package)
    }
  }
}

// MARK: NavigationDestination

extension SettingsDestinations: NavigationDestination {
  public var method: NavigationMethod {
    switch self {
    case .settings:
      .managedSheet
    default:
      .push
    }
  }

  public var body: some View {
    switch self {
    case .settings:
      SettingsView()
    case .security:
      SecuritySettingsView()
    case .accessibility:
      AccessibilitySettingsView()
    case .licenses:
      LicencesListView()
    case .imprint:
      ImprintView()
    case .lottie:
      LottieViewer()
    case .changePassword(let delegate):
      ChangePinCodeModuleWrapper(delegate: delegate)
        .edgesIgnoringSafeArea(.all)
    case .biometrics(let delegate):
      BiometricChangeModuleWrapper(delegate: delegate)
        .edgesIgnoringSafeArea(.all)
    case .diagnosticData:
      DiagnosticDataSettingsView()
    case .activityHistory:
      ActivityHistorySettingsView()
    case .licenseDetail(let package):
      LicenceDetailView(package: package)
    }
  }
}
