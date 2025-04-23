import Factory
import XCTest
@testable import BITCore
@testable import BITCredentialShared
@testable import BITInvitation
@testable import BITOpenID
@testable import BITSdJWT

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class GetCredentialIssuerDisplayUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    Container.shared.preferredUserLanguageCodes.register { self.preferredUserLanguageCodes }

    preferredUserLanguageCodes = []

    useCase = GetCredentialIssuerDisplayUseCase()
  }

  func testExecute_trustStatementInPreferredLanguage_returnsNameFromTrustStatement() {
    preferredUserLanguageCodes = ["en", "de"]
    useCase = GetCredentialIssuerDisplayUseCase()

    let issuer = useCase.execute(for: Self.credentialId, trustStatement: trustStatementMock, fallbackDisplay: fallbackDisplayMock)

    XCTAssertEqual(issuer?.credentialId, Self.credentialId)
    XCTAssertEqual(issuer?.name, Self.trustStatementNameEN)
    XCTAssertEqual(issuer?.image, Self.image)
  }

  func testExecute_trustStatementInDefaultLanguage_returnsNameFromTrustStatement() {
    let issuer = useCase.execute(for: Self.credentialId, trustStatement: trustStatementMock, fallbackDisplay: fallbackDisplayMock)

    XCTAssertEqual(issuer?.credentialId, Self.credentialId)
    XCTAssertEqual(issuer?.name, Self.trustStatementNameEN)
    XCTAssertEqual(issuer?.image, Self.image)
  }

  func testExecute_trustStatementWithPreferredLanguage_returnsNameFromTrustStatement() {
    let italianSample = TrustStatementPayload.Mock.validSampleItalian

    let issuer = useCase.execute(for: Self.credentialId, trustStatement: italianSample, fallbackDisplay: fallbackDisplayMock)

    XCTAssertEqual(issuer?.credentialId, Self.credentialId)
    XCTAssertEqual(issuer?.name, Self.trustStatementNameIT)
    XCTAssertEqual(issuer?.image, Self.image)
  }

  func testExecute_trustStatementNotMatchingLanguage_returnsNameFromKey() {
    UserLanguageCode.defaultAppLanguageCode = UserLocale.LanguageIdentifier.italian.rawValue

    let issuer = useCase.execute(for: Self.credentialId, trustStatement: TrustStatementPayload.Mock.validSample, fallbackDisplay: fallbackDisplayMock)

    XCTAssertEqual(issuer?.credentialId, Self.credentialId)
    XCTAssertEqual(issuer?.name, "orgName")
    XCTAssertEqual(issuer?.image, Self.image)

    UserLanguageCode.defaultAppLanguageCode = UserLocale.LanguageIdentifier.english.rawValue
  }

  // MARK: Private

  private static let trustStatementNameEN = "EN orgName"
  private static let trustStatementNameIT = "IT orgName"
  private static let fallbackIssuerName = "fallback"
  private static let image = "image".data(using: .utf8)!
  private static let credentialId = UUID()

  private let trustStatementMock = TrustStatementPayload.Mock.validSample
  private var preferredUserLanguageCodes: [UserLanguageCode] = []

  private var useCase: GetCredentialIssuerDisplayUseCase!

  private var fallbackDisplayMock: CredentialIssuerDisplay {
    CredentialIssuerDisplay(name: Self.fallbackIssuerName, credentialId: Self.credentialId, image: Self.image)
  }
  // swiftlint:enable force_unwrapping implicitly_unwrapped_optional

}
