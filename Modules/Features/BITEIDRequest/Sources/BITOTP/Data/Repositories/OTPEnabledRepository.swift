import Foundation

struct OTPEnabledRepository: OTPEnabledRepositoryProtocol {

  // MARK: Internal

  func set(_ enabled: Bool) {
    UserDefaults.standard.set(enabled, forKey: key)
  }

  func get() -> Bool {
    UserDefaults.standard.bool(forKey: key)
  }

  // MARK: Private

  private let key = "otpEnabled"
}
