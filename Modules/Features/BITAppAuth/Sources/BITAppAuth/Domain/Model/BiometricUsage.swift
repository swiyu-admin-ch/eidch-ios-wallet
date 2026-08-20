// MARK: - BiometricUsage

/// Represents the user Biometric usage (based on UserDefault)
public enum BiometricUsage: String {
  case enabled
  case disabled
  case declined
}

extension BiometricUsage {

  func toBiometricState() -> BiometricState {
    switch self {
    case .enabled:
      .enabled
    case .disabled:
      .disabled
    case .declined:
      .declined
    }
  }
}
