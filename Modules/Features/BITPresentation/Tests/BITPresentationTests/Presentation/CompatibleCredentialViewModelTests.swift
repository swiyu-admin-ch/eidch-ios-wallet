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

    router.delegate = presentationFinishDelegateMock

    viewModel = CompatibleCredentialViewModel(context: Self.contextMock, router: router)
  }

  @MainActor
  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    viewModel = CompatibleCredentialViewModel(context: Self.contextMock, router: router)

    XCTAssertEqual(viewModel.verifierDisplay.name, "EN entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(viewModel.verifierDisplay.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, Self.contextMock.trustInformation)
  }

  @MainActor
  func testDidSelect_navigatesAndSelectsCredential() {
    let selectedCredential = CompatibleCredential.Mock.diploma
    let context = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sample, compatibleCredentials: [.Mock.BIT, selectedCredential], trustInformation: .Mock.trustedIdentity)
    XCTAssertNil(context.selectedCredential)
    viewModel = CompatibleCredentialViewModel(context: context, router: router)

    viewModel.didSelect(credential: selectedCredential.credential)

    XCTAssertTrue(router.didCallPresentationReview)
    XCTAssertEqual(context.selectedCredential, selectedCredential)
  }

  @MainActor
  func testCancel_delegateCancelCalled() {
    viewModel.cancel()

    XCTAssertEqual(presentationFinishDelegateMock.cancelCalled, true)
  }

  // MARK: Private

  private static let contextMock = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

  private let themeMock = "light"

  private var viewModel: CompatibleCredentialViewModel!

  private let router = MockPresentationRouter()
  private let presentationFinishDelegateMock = MockPresentationFinishDelegate()
}
