import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try weak_delegate

@MainActor
final class CancelledStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    delegate = RequestCaseViewStateDelegateSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()

    Container.shared.deleteEIDRequestCaseUseCase.register { self.deleteEIDRequestCaseUseCase }
  }

  func testInitialState() throws {
    viewModel = try CancelledStateViewModel(requestCase: mockRequestCase, delegate: delegate)

    XCTAssertEqual(viewModel.fullName, "\(mockRequestCase.firstName) \(mockRequestCase.lastName)")
    XCTAssertEqual(viewModel.id, mockRequestCase.id)
    XCTAssertNotNil(viewModel.delegate)
  }

  func testDeleteRequestCase_success() async throws {
    viewModel = try CancelledStateViewModel(requestCase: mockRequestCase, delegate: delegate)

    await viewModel.deleteRequestCase()

    XCTAssertEqual(deleteEIDRequestCaseUseCase.executeReceivedId, mockRequestCase.id)
    XCTAssertTrue(delegate.didDeleteRequestCaseCalled)
  }

  func testDeleteRequestCase_useCaseThrows_throwsError() async throws {
    viewModel = try CancelledStateViewModel(requestCase: mockRequestCase, delegate: delegate)

    deleteEIDRequestCaseUseCase.executeThrowableError = TestingError.error

    await viewModel.deleteRequestCase()

    XCTAssertFalse(delegate.didDeleteRequestCaseCalled)
  }

  func testOpenFAQ_success() throws {
    viewModel = try CancelledStateViewModel(requestCase: mockRequestCase, delegate: delegate)

    viewModel.openFAQ()

    XCTAssertTrue(delegate.didOpenExternalLinkUrlCalled)
  }

  // MARK: Private

  private let mockRequestCase: EIDRequestCase = .Mock.sampleCancelled
  private var delegate: RequestCaseViewStateDelegateSpy!
  private var viewModel: CancelledStateViewModel!
  private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy!
}
