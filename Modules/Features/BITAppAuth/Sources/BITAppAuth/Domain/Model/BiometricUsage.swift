// MARK: - BiometricUsage

/// Represents the user's in-app biometric opt-in preference (persisted in UserDefaults).
///
/// This is intentionally limited to the user's choice. Whether biometrics are actually usable
/// (permission granted, enrolled, hardware present) is a system fact read live from `LAContext`,
/// never persisted here.
public enum BiometricUsage: String, Sendable {
  case enabled
  case disabled
}

extension BiometricUsage {

  func toBiometricState() -> BiometricState {
    switch self {
    case .enabled:
      .enabled
    case .disabled:
      .disabled
    }
  }
}
