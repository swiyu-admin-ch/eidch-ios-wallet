// swiftlint:disable all
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@MainActor
class ExpiredStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    delegate = RequestCaseViewStateDelegateSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()

    Container.shared.deleteEIDRequestCaseUseCase.register { @MainActor in self.deleteEIDRequestCaseUseCase }
  }

  func testInit_validRequestCase_success() throws {
    viewModel = try ExpiredStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    XCTAssertEqual(viewModel.fullName, "\(mockEidRequestCase.firstName) \(mockEidRequestCase.lastName)")
    XCTAssertEqual(viewModel.id, mockEidRequestCase.id)
    XCTAssertNotNil(viewModel.delegate)
  }

  func testDeleteRequestCase_success() async throws {
    viewModel = try ExpiredStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    await viewModel.primaryAction()

    XCTAssertEqual(deleteEIDRequestCaseUseCase.executeReceivedId, mockEidRequestCase.id)
    XCTAssertTrue(delegate.didDeleteRequestCaseCalled)
  }

  func testDeleteRequestCase_failure() async throws {
    deleteEIDRequestCaseUseCase.executeThrowableError = TestingError.error

    viewModel = try ExpiredStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    await viewModel.primaryAction()

    XCTAssertFalse(delegate.didDeleteRequestCaseCalled)
  }

  // MARK: Private

  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleExpired
  private var delegate: RequestCaseViewStateDelegateSpy!
  private var viewModel: ExpiredStateViewModel!
  private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy!
}

// swiftlint:enable all
