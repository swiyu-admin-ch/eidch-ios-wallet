// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared

final class GetCredentialDisplayUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    useCase = GetCredentialDisplayUseCase()
  }

  func testExecute_firstLanguageWithLightTheme_returnsFirstLanguageInTheme() {
    mockPreferredLanguages(["de", "en"])

    let result = useCase.execute(for: credential.displays, colorScheme: "light")

    XCTAssertEqual(result?.name, "de-CH light")
  }

  func testExecute_firstLanguageWithDarkTheme_returnsFirstLanguageInTheme() {
    mockPreferredLanguages(["de", "en"])

    let result = useCase.execute(for: credential.displays, colorScheme: "dark")

    XCTAssertEqual(result?.name, "de-CH dark")
  }

  func testExecute_firstNotAvailable_fallsBackToSecondLanguageInTheme() {
    mockPreferredLanguages(["it", "de"])

    let result = useCase.execute(for: credential.displays, colorScheme: "dark")

    XCTAssertEqual(result?.name, "de-CH dark")
  }

  func testExecute_preferredWithoutTheme_returnsFirstOfPreferred() {
    mockPreferredLanguages(["fr"])

    let result = useCase.execute(for: credential.displays, colorScheme: "dark")

    XCTAssertEqual(result?.name, "fr-CH no theme")
  }

  func testExecute_notMatchingPreferredLanguage_returnsFirstInTheme() {
    mockPreferredLanguages([])

    let result = useCase.execute(for: credential.displays, colorScheme: "dark")

    XCTAssertEqual(result?.name, "de-CH dark")
  }

  // MARK: Private

  private let credential = Credential.Mock.displaysThemed
  private var useCase: GetCredentialDisplayUseCase!

  private func mockPreferredLanguages(_ languages: [String]) {
    Container.shared.preferredUserLanguageCodes.register { languages }
    useCase = GetCredentialDisplayUseCase()
  }

}

// swiftlint:enable all
