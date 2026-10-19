// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@MainActor
class UnknownStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    delegate = RequestCaseViewStateDelegateSpy()
    let updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    self.updateEIDRequestCaseStatusUseCase = updateEIDRequestCaseStatusUseCase

    Container.shared.updateEIDRequestCaseStatusUseCase.register { @MainActor in updateEIDRequestCaseStatusUseCase }
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testInit_validRequestCase_success() throws {
    viewModel = try UnknownStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    XCTAssertEqual(viewModel.fullName, "\(mockEidRequestCase.firstName) \(mockEidRequestCase.lastName)")
    XCTAssertEqual(viewModel.id, mockEidRequestCase.id)
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
  // swiftlint:disable:next weak_delegate
  private var delegate: RequestCaseViewStateDelegateSpy!
  private var viewModel: UnknownStateViewModel!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional
