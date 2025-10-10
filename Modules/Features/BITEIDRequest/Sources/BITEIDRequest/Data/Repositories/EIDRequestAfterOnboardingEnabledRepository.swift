import Foundation

struct EIDRequestAfterOnboardingEnabledRepository: EIDRequestAfterOnboardingEnabledRepositoryProcotol {

  private let key = "eIDRequestAfterOnboardingEnabled"

  func set(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: key)
  }

  func get() -> Bool {
    UserDefaults.standard.bool(forKey: key)
  }

}
