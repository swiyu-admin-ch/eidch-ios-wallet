import BITL10n
import Factory
import Testing
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITPushNotification
@testable import BITTestingCore

// MARK: - ExpiredStateViewModelTests

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try weak_delegate

@MainActor
struct ExpiredStateViewModelTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let delegate = RequestCaseViewStateDelegateSpy()
    let deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()
    let deletePushIdUseCase = DeletePushIdUseCaseProtocolSpy()

    self.delegate = delegate
    self.deleteEIDRequestCaseUseCase = deleteEIDRequestCaseUseCase
    self.deletePushIdUseCase = deletePushIdUseCase

    Container.shared.deleteEIDRequestCaseUseCase.register { @MainActor in deleteEIDRequestCaseUseCase }
    Container.shared.deletePushIdUseCase.register { deletePushIdUseCase }

    viewModel = try! ExpiredStateViewModel(requestCase: mockRequestCase, delegate: delegate)
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(viewModel.notificationTitle == L10n.tkEidRequestNotificationEidExpiredPrimary(viewModel.fullName))
    #expect(viewModel.notificationContent == L10n.tkEidRequestNotificationEidExpiredSecondary)
    #expect(viewModel.id == mockRequestCase.id)
    #expect(viewModel.delegate != nil)
  }

  @Test
  func primaryAction_success() async {
    await viewModel.primaryAction()

    #expect(deletePushIdUseCase.callAsFunctionCallsCount == 1)
    #expect(deletePushIdUseCase.callAsFunctionReceivedPushId == mockRequestCase.pushId)
    #expect(deleteEIDRequestCaseUseCase.executeReceivedId == mockRequestCase.id)
    #expect(delegate.didDeleteRequestCaseCalled)
  }

  @Test
  func primaryAction_withoutPushId_deletesRequestCase() async throws {
    var requestCase = mockRequestCase
    requestCase.pushId = nil
    let viewModel = try makeViewModel(requestCase: requestCase)

    await viewModel.primaryAction()

    #expect(!deletePushIdUseCase.callAsFunctionCalled)
    #expect(deleteEIDRequestCaseUseCase.executeReceivedId == requestCase.id)
    #expect(delegate.didDeleteRequestCaseCalled)
  }

  @Test
  func primaryAction_deleteEIDRequestThrows_silentlyFails() async {
    deleteEIDRequestCaseUseCase.executeThrowableError = TestingError.error

    await viewModel.primaryAction()

    #expect(deletePushIdUseCase.callAsFunctionReceivedPushId == mockRequestCase.pushId)
    #expect(!delegate.didDeleteRequestCaseCalled)
  }

  @Test
  func primaryAction_deletePushIdThrows_silentlyFails() async {
    deletePushIdUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.primaryAction()

    #expect(deletePushIdUseCase.callAsFunctionReceivedPushId == mockRequestCase.pushId)
    #expect(!deleteEIDRequestCaseUseCase.executeCalled)
    #expect(!delegate.didDeleteRequestCaseCalled)
  }

  // MARK: Private

  private let mockRequestCase: EIDRequestCase = .Mock.sampleExpired
  private let delegate: RequestCaseViewStateDelegateSpy
  private let deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy
  private let deletePushIdUseCase: DeletePushIdUseCaseProtocolSpy
  private let viewModel: ExpiredStateViewModel

  private func makeViewModel(requestCase: EIDRequestCase? = nil) throws -> ExpiredStateViewModel {
    try ExpiredStateViewModel(requestCase: requestCase ?? mockRequestCase, delegate: delegate)
  }
}
