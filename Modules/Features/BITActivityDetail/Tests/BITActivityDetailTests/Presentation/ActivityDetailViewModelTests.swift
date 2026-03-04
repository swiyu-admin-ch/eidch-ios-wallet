// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITActivityDetail
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTestingCore

@MainActor
final class ActivityDetailViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    viewModel = ActivityDetailViewModel(activityMock, credentialId: credentialIdMock)
    createSuccessState()
  }

  func testFetchCredential_activityWithClaims_stateIsResultWithCredential() async {
    await viewModel.fetchCredential()

    if case .result(let activity, let credential) = viewModel.state {
      XCTAssertEqual(activity.activity, activityMock)
      XCTAssertNotNil(credential?.name)
      XCTAssertEqual(credential?.clusters.count, 1)
    } else {
      XCTFail("Expected result state")
    }
  }

  func testFetchCredential_activityNoClaims_stateIsResultWithCredentialAndNoClusters() async {
    let activityMock = Activity.Mock.presentationAcceptedTrusted
    viewModel = ActivityDetailViewModel(activityMock, credentialId: credentialIdMock)

    await viewModel.fetchCredential()

    if case .result(let activity, let credential) = viewModel.state {
      XCTAssertEqual(activity.activity, activityMock)
      XCTAssertNotNil(credential?.name)
      XCTAssertTrue(credential?.clusters.isEmpty == true)
    } else {
      XCTFail("Expected result state")
    }
  }

  func testFetchCredential_deferredCredential_stateIsError() async {
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = DeferredCredential.Mock.sample

    await viewModel.fetchCredential()

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? ActivityDetailViewModelError, .unsupportedCredentialType)
    } else {
      XCTFail("Expected error state")
    }
  }

  func testFetchCredential_useCaseThrowsError_stateIsError() async {
    getCredentialUseCaseSpy.callAsFunctionIdThrowableError = TestingError.error

    await viewModel.fetchCredential()

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? TestingError, .error)
    } else {
      XCTFail("Expected error state")
    }
  }

  func testShowDeleteActivityConfirmation_deleteConfirmationPresented() {
    XCTAssertFalse(viewModel.isDeleteConfirmationPresented)

    viewModel.showDeleteActivityConfirmation()

    XCTAssertTrue(viewModel.isDeleteConfirmationPresented)
  }

  func testDeleteActivity_success_hidesDeleteConfirmation() {
    viewModel.isDeleteConfirmationPresented = true

    viewModel.deleteActivity()

    XCTAssertFalse(viewModel.isDeleteConfirmationPresented)
    XCTAssertEqual(deleteActivityUseCaseSpy.callAsFunctionCallsCount, 1)
    XCTAssertEqual(deleteActivityUseCaseSpy.callAsFunctionReceivedActivityId, activityMock.id)
  }

  func testDeleteActivity_useCaseThrowsError_justRuns() {
    viewModel.isDeleteConfirmationPresented = true
    deleteActivityUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    viewModel.deleteActivity()

    XCTAssertFalse(viewModel.isDeleteConfirmationPresented)
  }

  func testShowNonComplianceReportSent_setsToast() {
    XCTAssertNil(viewModel.toastMessage)
    XCTAssertFalse(viewModel.isToastPresented)

    viewModel.showNonComplianceReportSent()

    XCTAssertEqual(viewModel.toastMessage, L10n.tkActivityActivityListNonComplianceReportSentTitle)
    XCTAssertTrue(viewModel.isToastPresented)
  }

  func testClearToast_resetsToastState() {
    viewModel.showNonComplianceReportSent()

    viewModel.clearToast()

    XCTAssertNil(viewModel.toastMessage)
    XCTAssertFalse(viewModel.isToastPresented)
  }

  // MARK: Private

  private let credentialIdMock = UUID()
  private let activityMock = Activity.Mock.issueTrusted
  private let credentialMock = VerifiableCredential.Mock.sample

  private var getCredentialUseCaseSpy: GetCredentialUseCaseProtocolSpy!
  private var deleteActivityUseCaseSpy: DeleteActivityUseCaseProtocolSpy!

  private var viewModel: ActivityDetailViewModel!

  private func registerMocks() {
    getCredentialUseCaseSpy = GetCredentialUseCaseProtocolSpy()
    deleteActivityUseCaseSpy = DeleteActivityUseCaseProtocolSpy()
    Container.shared.getCredentialUseCase.register { self.getCredentialUseCaseSpy }
    Container.shared.deleteActivityUseCase.register { self.deleteActivityUseCaseSpy }
  }

  private func createSuccessState() {
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = credentialMock
  }
}
