import BITL10n
import Factory
import Testing
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITPushNotification
@testable import BITTestingCore

// MARK: - CancelledStateViewModelTests

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try weak_delegate

@MainActor
struct CancelledStateViewModelTests {

  // MARK: Lifecycle

  init() {
    let delegate = RequestCaseViewStateDelegateSpy()
    let deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()
    let deletePushIdUseCase = DeletePushIdUseCaseProtocolSpy()

    self.delegate = delegate
    self.deleteEIDRequestCaseUseCase = deleteEIDRequestCaseUseCase
    self.deletePushIdUseCase = deletePushIdUseCase

    Container.shared.deleteEIDRequestCaseUseCase.register { @MainActor in deleteEIDRequestCaseUseCase }
    Container.shared.deletePushIdUseCase.register { deletePushIdUseCase }

    viewModel = try! CancelledStateViewModel(requestCase: mockRequestCase, delegate: delegate)
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(viewModel.notificationTitle == L10n.tkEidRequestNotificationCancelledPrimary)
    #expect(viewModel.notificationContent == L10n.tkEidRequestNotificationCancelledSecondary)
    #expect(viewModel.id == mockRequestCase.id)
    #expect(viewModel.delegate != nil)
  }

  @Test
  func deleteRequestCase_success() async {
    await viewModel.deleteRequestCase()

    #expect(deletePushIdUseCase.callAsFunctionCallsCount == 1)
    #expect(deletePushIdUseCase.callAsFunctionReceivedPushId == mockRequestCase.pushId)
    #expect(deleteEIDRequestCaseUseCase.executeReceivedId == mockRequestCase.id)
    #expect(delegate.didDeleteRequestCaseCalled)
  }

  @Test
  func deleteRequestCase_withoutPushId_deletesRequestCase() async throws {
    var requestCase = mockRequestCase
    requestCase.pushId = nil
    let viewModel = try makeViewModel(requestCase: requestCase)

    await viewModel.deleteRequestCase()

    #expect(!deletePushIdUseCase.callAsFunctionCalled)
    #expect(deleteEIDRequestCaseUseCase.executeReceivedId == requestCase.id)
    #expect(delegate.didDeleteRequestCaseCalled)
  }

  @Test
  func deleteRequestCase_deleteEIDRequestThrows_silentlyFails() async {
    deleteEIDRequestCaseUseCase.executeThrowableError = TestingError.error

    await viewModel.deleteRequestCase()

    #expect(deletePushIdUseCase.callAsFunctionReceivedPushId == mockRequestCase.pushId)
    #expect(!delegate.didDeleteRequestCaseCalled)
  }

  @Test
  func deleteRequestCase_deletePushIdThrows_silentlyFails() async {
    deletePushIdUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.deleteRequestCase()

    #expect(deletePushIdUseCase.callAsFunctionReceivedPushId == mockRequestCase.pushId)
    #expect(!deleteEIDRequestCaseUseCase.executeCalled)
    #expect(!delegate.didDeleteRequestCaseCalled)
  }

  // MARK: Private

  private let mockRequestCase: EIDRequestCase = .Mock.sampleCancelled
  private let delegate: RequestCaseViewStateDelegateSpy
  private let deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy
  private let deletePushIdUseCase: DeletePushIdUseCaseProtocolSpy
  private let viewModel: CancelledStateViewModel

  private func makeViewModel(requestCase: EIDRequestCase? = nil) throws -> CancelledStateViewModel {
    try CancelledStateViewModel(requestCase: requestCase ?? mockRequestCase, delegate: delegate)
  }
}
