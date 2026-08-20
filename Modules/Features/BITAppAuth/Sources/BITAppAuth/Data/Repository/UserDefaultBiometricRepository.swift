import Foundation
import Spyable

// MARK: - BiometricRepositoryProtocol

@Spyable
public protocol BiometricRepositoryProtocol {
  func setBiometricUsage(_ usage: BiometricUsage)
  func getBiometricUsage() -> BiometricUsage
}

// MARK: - UserDefaultBiometricRepository

struct UserDefaultBiometricRepository: BiometricRepositoryProtocol {

  // MARK: Lifecycle

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }

  // MARK: Internal

  func setBiometricUsage(_ usage: BiometricUsage) {
    userDefaults.set(usage.rawValue, forKey: usageKey)
  }

  func getBiometricUsage() -> BiometricUsage {
    guard let rawValue = userDefaults.string(forKey: usageKey) else {
      return migrateFromLegacyKey()
    }

    return BiometricUsage(rawValue: rawValue) ?? .declined
  }

  // MARK: Private

  private let usageKey = "biometricUsageKey"
  private let legacyKey = "isBiometricUsageAllowed"
  private let userDefaults: UserDefaults

  private func migrateFromLegacyKey() -> BiometricUsage {
    guard userDefaults.object(forKey: legacyKey) != nil else {
      return .declined
    }

    let usage: BiometricUsage = userDefaults.bool(forKey: legacyKey) ? .enabled : .disabled

    userDefaults.set(usage.rawValue, forKey: usageKey)
    userDefaults.removeObject(forKey: legacyKey)

    return usage
  }
}
