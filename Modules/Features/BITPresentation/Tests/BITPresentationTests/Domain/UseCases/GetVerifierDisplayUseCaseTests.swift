import Factory
import Spyable
import XCTest
@testable import BITCore
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional force_try

final class GetVerifierDisplayUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    preferredUserLanguageCodes = ["en", "de"]
    Container.shared.preferredUserLanguageCodes.register { self.preferredUserLanguageCodes }

    useCase = GetVerifierDisplayUseCase()
  }

  func testExecute_withoutTrustStatement_returnsUntrustedNameFromVerifier() {
    let verifierDisplay = useCase.execute(for: verifierMock, trustStatement: nil)

    XCTAssertEqual(verifierDisplay?.trustStatus, .unverified)
    XCTAssertEqual(verifierDisplay?.name, Self.clientNameEN)
    XCTAssertEqual(verifierDisplay?.logo, Self.logoStringEN.data(using: .utf8))
  }

  func testExecute_trustStatementInPreferredLanguage_returnsNameFromTrustStatement() {
    let verifierDisplay = useCase.execute(for: verifierMock, trustStatement: trustStatementMock)

    XCTAssertEqual(verifierDisplay?.trustStatus, .verified)
    XCTAssertEqual(verifierDisplay?.name, Self.trustStatementNameEN)
    XCTAssertEqual(verifierDisplay?.logo, Self.logoStringEN.data(using: .utf8))
  }

  func testExecute_trustStatementNotMatchingLanguage_returnsNameFromKey() {
    preferredUserLanguageCodes = []
    useCase = GetVerifierDisplayUseCase()

    let verifierDisplay = useCase.execute(for: verifierMock, trustStatement: trustStatementMock)

    XCTAssertEqual(verifierDisplay?.trustStatus, .verified)
    XCTAssertEqual(verifierDisplay?.name, "entityName")
    XCTAssertNil(verifierDisplay?.logo)
  }

  // MARK: Private

  private static var clientNameEN = "EN clientName"
  private static var clientNameIT = "IT clientName"
  private static var logoStringEN = "enLogo"
  private static var logoStringIT = "itLogo"
  private static var logoUriEN = URL(string: "data:,\(logoStringEN)")!
  private static var logoUriIT = URL(string: "data:,\(logoStringIT)")!

  private static let trustStatementNameEN = "EN entityName"
  private static let trustStatementNameIT = "IT entityName"

  private var verifierMock = createVerifier()
  private let trustStatementMock = TrustStatementPayload.Mock.validSample

  private var preferredUserLanguageCodes: [UserLanguageCode] = []

  private var useCase: GetVerifierDisplayUseCase!

  private static func createVerifier(multipleLanguages: Bool = false) -> Verifier {
    var names = ["en": Self.clientNameEN]
    var logos = ["en": Self.logoUriEN]
    if multipleLanguages {
      names["it"] = Self.clientNameIT
      logos["it"] = Self.logoUriIT
    }
    let clientName = ClientMetadata.LocalizedDisplay(values: names)
    let logoUri = ClientMetadata.LocalizedDisplay(values: logos)
    return try! Verifier(clientName: clientName, logoUri: logoUri)
  }
  // swiftlint:enable force_unwrapping implicitly_unwrapped_optional force_try

}
