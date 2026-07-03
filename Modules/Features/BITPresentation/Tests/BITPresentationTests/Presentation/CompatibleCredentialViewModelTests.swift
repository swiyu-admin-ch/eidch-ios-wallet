// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation

// MARK: - CompatibleCredentialViewModelTests

final class CompatibleCredentialViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()
    Container.shared.reset()

    viewModel = CompatibleCredentialViewModel(context: Self.contextMock)
  }

  @MainActor
  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    viewModel = CompatibleCredentialViewModel(context: Self.contextMock)

    XCTAssertEqual(viewModel.verifierDisplay.name, "EN entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(viewModel.verifierDisplay.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, Self.contextMock.trustInformation)
  }

  @MainActor
  func testDidSelect_navigatesAndSelectsCredential() {
    let selectedCredential = CompatibleCredential.Mock.diploma
    let context = PresentationRequestContext(requestObjectJWS: .Mock.sample, compatibleCredentials: [.Mock.BIT, selectedCredential], trustInformation: .Mock.trustedIdentity)
    XCTAssertNil(context.selectedCredential)
    viewModel = CompatibleCredentialViewModel(context: context)

    viewModel.didSelect(credential: selectedCredential.credential)

    XCTAssertEqual(context.selectedCredential, selectedCredential)
    switch viewModel.destination {
    case .requestReview(let destinationContext):
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected request review destination")
    }
  }

  // MARK: Private

  private static let contextMock = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

  private var viewModel: CompatibleCredentialViewModel!
}
