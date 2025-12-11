// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITCredential
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

class PresentationRequestResultStateViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    Container.shared.reset()
    router = MockPresentationRouter()
    router.delegate = presentationFinishDelegateMock

    viewModel = PresentationRequestResultStateViewModel(state: .error, context: context, router: router)
  }

  @MainActor
  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    viewModel = PresentationRequestResultStateViewModel(state: .error, context: context, router: router)

    XCTAssertEqual(viewModel.verifierDisplay.name, "EN entityName")
    XCTAssertEqual(String(data: viewModel.verifierDisplay.logo!, encoding: .utf8)!, "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, context.trustInformation)
  }

  @MainActor
  func testFinish_delegateFinishCalled() async throws {
    await viewModel.finish()

    XCTAssertEqual(presentationFinishDelegateMock.finishCalled, true)
  }

  @MainActor
  func testRetry_delegateRetryCalled() async throws {
    viewModel.retry()

    XCTAssertEqual(presentationFinishDelegateMock.retryCalled, true)
  }

  // MARK: Private

  private var viewModel: PresentationRequestResultStateViewModel!
  private let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust
  private var router = MockPresentationRouter()
  private let presentationFinishDelegateMock = MockPresentationFinishDelegate()
  // swiftlint:enable all
}
