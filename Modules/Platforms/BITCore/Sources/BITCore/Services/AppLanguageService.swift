import Factory
import Foundation

// MARK: - AppLanguageServiceProtocol

public protocol AppLanguageServiceProtocol {
  func syncAppLanguageCodes() throws
  func getAppLanguageCodes() throws -> [UserLanguageCode]
}

// MARK: - AppLanguageService

struct AppLanguageService: AppLanguageServiceProtocol {

  // MARK: Internal

  func syncAppLanguageCodes() throws {
    guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
      throw AppLanguageServiceError.invalidSuiteName
    }

    userDefaults.set(preferredUserLanguageCodes, forKey: languageCodesKey)
  }

  func getAppLanguageCodes() throws -> [UserLanguageCode] {
    guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
      throw AppLanguageServiceError.invalidSuiteName
    }

    return userDefaults.stringArray(forKey: languageCodesKey) ?? []
  }

  // MARK: Private

  private let languageCodesKey = "appLanguageCodes"

  @Injected(\.appGroupIdentifier) private var appGroupIdentifier
  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]

}

// MARK: - AppLanguageServiceError

enum AppLanguageServiceError: Error {
  case invalidSuiteName
}
