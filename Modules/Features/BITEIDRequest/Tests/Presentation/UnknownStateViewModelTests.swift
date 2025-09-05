// swiftlint:disable all
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@MainActor
class UnknownStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    delegate = RequestCaseViewStateDelegateSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()

    Container.shared.updateEIDRequestCaseStatusUseCase.register { self.updateEIDRequestCaseStatusUseCase }
  }

  func testInit_validRequestCase_success() throws {
    viewModel = try UnknownStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    XCTAssertEqual(viewModel.fullName, "\(mockEidRequestCase.firstName) \(mockEidRequestCase.lastName)")
    XCTAssertEqual(viewModel.requestCaseId, mockEidRequestCase.id)
    XCTAssertNotNil(viewModel.delegate)
  }

  func testPrimaryAction_success() async throws {
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = mockEidRequestCase
    viewModel = try UnknownStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    await viewModel.primaryAction()

    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForReceivedRequestCaseId, mockEidRequestCase.id)
    XCTAssertTrue(delegate.didUpdateRequestCaseStateCalled)
  }

  func testPrimaryAction_failure() async throws {
    updateEIDRequestCaseStatusUseCase.executeForThrowableError = TestingError.error
    viewModel = try UnknownStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    await viewModel.primaryAction()

    XCTAssertFalse(delegate.didUpdateRequestCaseStateCalled)
  }

  // MARK: Private

  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleWithoutState
  private var delegate: RequestCaseViewStateDelegateSpy!
  private var viewModel: UnknownStateViewModel!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
}

// swiftlint:enable all
