import Factory
import Foundation
import Testing
@testable import BITCore

struct AppLanguageServiceTests {

  // MARK: Lifecycle

  init() {
    let appGroupIdentifier = mockAppGroupIdentifier
    Container.shared.appGroupIdentifier.register { appGroupIdentifier }
    Container.shared.preferredUserLanguageCodes.register { ["fr", "en"] }

    service = AppLanguageService()
  }

  // MARK: Internal

  @Test
  func syncAppLanguageCodes_writesLanguageCodes() throws {
    let userDefaults = UserDefaults(suiteName: mockAppGroupIdentifier)

    try service.syncAppLanguageCodes()

    #expect(userDefaults?.stringArray(forKey: languageCodesKey) == ["fr", "en"])
  }

  @Test
  func getAppLanguageCodes_readsLanguageCodes() throws {
    let userDefaults = UserDefaults(suiteName: mockAppGroupIdentifier)

    userDefaults?.set(["de", "en"], forKey: languageCodesKey)

    #expect(try service.getAppLanguageCodes() == ["de", "en"])
  }

  // MARK: Private

  private let service: AppLanguageService
  private let languageCodesKey = "appLanguageCodes"
  private let mockAppGroupIdentifier = "mock_app_group_identifier"
}
