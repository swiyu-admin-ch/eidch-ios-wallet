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

  @Test(arguments: [BiometricUsage.enabled, .disabled, .declined])
  func setBiometricUsage_persistsUsage(_ usage: BiometricUsage) {
    repository.setBiometricUsage(usage)

    #expect(repository.getBiometricUsage() == usage)
    #expect(UserDefaults.standard.string(forKey: usageKey) == usage.rawValue)
  }

  @Test
  func getBiometricUsage_invalidStoredUsage_returnsSkipped() {
    UserDefaults.standard.set("invalid", forKey: usageKey)

    #expect(repository.getBiometricUsage() == .declined)
  }

  @Test
  func getBiometricUsage_legacyValue_migratesAndRemovesLegacyKey() {
    UserDefaults.standard.set(true, forKey: legacyKey)

    #expect(repository.getBiometricUsage() == .enabled)
    #expect(UserDefaults.standard.string(forKey: usageKey) == BiometricUsage.enabled.rawValue)
    #expect(UserDefaults.standard.object(forKey: legacyKey) == nil)
  }

  @Test
  func getBiometricUsage_legacyValue_migratesSkipped() {
    UserDefaults.standard.removeObject(forKey: legacyKey)

    #expect(repository.getBiometricUsage() == .declined)
  }

  // MARK: Private

  private let repository = UserDefaultBiometricRepository()
  private let usageKey = "biometricUsageKey"
  private let legacyKey = "isBiometricUsageAllowed"
}
