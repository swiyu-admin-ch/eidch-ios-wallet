/// Represents the exact state of the Biometric for the app
public enum BiometricState {

  /// The permission is granted and user accepts to use it
  case enabled

  /// The permission is granted but user does NOT use it
  case disabled

  /// The permission was declined
  case declined

  /// Biometric is not setup on the device
  case notEnrolled
}
