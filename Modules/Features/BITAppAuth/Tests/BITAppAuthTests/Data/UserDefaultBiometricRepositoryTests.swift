import Foundation
import Testing
@testable import BITAppAuth

@MainActor
struct UserDefaultBiometricRepositoryTests {

  // MARK: Lifecycle

  init() {
    UserDefaults.standard.removeObject(forKey: usageKey)
    UserDefaults.standard.removeObject(forKey: legacyKey)
  }

  // MARK: Internal

  @Test(arguments: [BiometricUsage.enabled, .disabled])
  func setBiometricUsage_persistsUsage(_ usage: BiometricUsage) {
    repository.setBiometricUsage(usage)

    #expect(repository.getBiometricUsage() == usage)
    #expect(UserDefaults.standard.string(forKey: usageKey) == usage.rawValue)
  }

  @Test
  func getBiometricUsage_invalidStoredUsage_returnsDisabled() {
    UserDefaults.standard.set("invalid", forKey: usageKey)

    #expect(repository.getBiometricUsage() == .disabled)
  }

  @Test
  func getBiometricUsage_legacyDeclinedValue_returnsDisabled() {
    UserDefaults.standard.set("declined", forKey: usageKey)

    #expect(repository.getBiometricUsage() == .disabled)
  }

  @Test
  func getBiometricUsage_legacyValue_migratesAndRemovesLegacyKey() {
    UserDefaults.standard.set(true, forKey: legacyKey)

    #expect(repository.getBiometricUsage() == .enabled)
    #expect(UserDefaults.standard.string(forKey: usageKey) == BiometricUsage.enabled.rawValue)
    #expect(UserDefaults.standard.object(forKey: legacyKey) == nil)
  }

  @Test
  func getBiometricUsage_noStoredValue_returnsDisabled() {
    UserDefaults.standard.removeObject(forKey: legacyKey)

    #expect(repository.getBiometricUsage() == .disabled)
  }

  // MARK: Private

  private let repository = UserDefaultBiometricRepository()
  private let usageKey = "biometricUsageKey"
  private let legacyKey = "isBiometricUsageAllowed"
}
