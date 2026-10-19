import Foundation

@MainActor
public protocol BiometricChangeDelegate: AnyObject {
  func didBiometricStatusChange(to isEnabled: Bool)
}
