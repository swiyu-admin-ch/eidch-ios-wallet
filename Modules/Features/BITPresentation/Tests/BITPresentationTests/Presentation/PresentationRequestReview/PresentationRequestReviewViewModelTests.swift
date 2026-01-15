// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

@MainActor
class PresentationRequestReviewViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()

    viewModel = PresentationRequestReviewViewModel(context: context, router: router)
    viewModel.updateCredential(with: colorSchemeMock)
  }

  @MainActor
  func testInit_loadingWithoutAlert() {
    viewModel = PresentationRequestReviewViewModel(context: context, router: router)

    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.isUnknownVerifierAlertShown, false)
  }

  @MainActor
  func testUpdateCredential_loading_updatesStateToResult() {
    viewModel = PresentationRequestReviewViewModel(context: context, router: router)
    XCTAssertEqual(viewModel.state, .loading)

    viewModel.updateCredential(with: colorSchemeMock)

    if case .result(let viewState) = viewModel.state {
      XCTAssertEqual(viewState.credential.colorScheme, colorSchemeMock)
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  @MainActor
  func testUpdateCredential_result_updatesCredential() {
    if case .result(let oldViewState) = viewModel.state {
      let colorScheme = "other"
      viewModel.updateCredential(with: colorScheme)

      if case .result(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.credential.credential, oldViewState.credential.credential)
        XCTAssertEqual(viewState.credential.colorScheme, colorScheme)
        XCTAssertEqual(viewState.verifierDisplay, oldViewState.verifierDisplay)
        XCTAssertEqual(viewState.claimBadges, oldViewState.claimBadges)
        XCTAssertEqual(viewState.clusters, oldViewState.clusters)
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  @MainActor
  func testUpdateCredential_processing_updatesCredential() async {
    if case .result(let resultViewState) = viewModel.state {
      await viewModel.send(.submit(resultViewState, true))
      if case .processing(let oldViewState) = viewModel.state {
        let colorScheme = "other"

        viewModel.updateCredential(with: colorScheme)

        if case .processing(let viewState) = viewModel.state {
          XCTAssertEqual(viewState.credential.credential, oldViewState.credential.credential)
          XCTAssertEqual(viewState.credential.colorScheme, colorScheme)
          XCTAssertEqual(viewState.verifierDisplay, oldViewState.verifierDisplay)
          XCTAssertEqual(viewState.isMessagePresented, oldViewState.isMessagePresented)
          return
        }
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_Success_stateIsProcessingAndNavigatesToSuccess() async throws {
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, false))

      if case .processing(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.credential, oldViewState.credential)
        XCTAssertEqual(viewState.verifierDisplay, oldViewState.verifierDisplay)
        XCTAssertEqual(viewState.isMessagePresented, false)
        XCTAssertEqual(router.calledPresentationResultState, .success(claims: context.selectedCredential!.requestedClusteredClaims.flatMap(\.claims)))
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_Success_passesArguments() async throws {
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, false))

      if case .processing = viewModel.state {
        XCTAssertEqual(submitPresentationUseCase.executeContextCallsCount, 1)
        XCTAssertEqual(submitPresentationUseCase.executeContextReceivedContext?.requestObject, context.requestObject)
        XCTAssertFalse(declinePresentationUseCase.callAsFunctionContextCalled)
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_unknownTrustIdentity_showsAlert() async throws {
    viewModel = PresentationRequestReviewViewModel(context: .Mock.vcSdJwtWithUnknownIdentityTrust, router: router)
    viewModel.updateCredential(with: colorSchemeMock)
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, false))

      if case .result = viewModel.state {
        XCTAssertTrue(viewModel.isUnknownVerifierAlertShown)
        XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
        XCTAssertFalse(declinePresentationUseCase.callAsFunctionContextCalled)
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_unknownTrustIdentityWithForce_navigatesToSuccess() async throws {
    viewModel = PresentationRequestReviewViewModel(context: .Mock.vcSdJwtWithUnknownIdentityTrust, router: router)
    viewModel.updateCredential(with: colorSchemeMock)
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, true))

      if case .processing(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.credential, oldViewState.credential)
        XCTAssertEqual(viewState.verifierDisplay, oldViewState.verifierDisplay)
        XCTAssertEqual(viewState.isMessagePresented, false)
        XCTAssertEqual(router.calledPresentationResultState, .success(claims: context.selectedCredential!.requestedClusteredClaims.flatMap(\.claims)))
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_useCaseThrowsError_navigatesToError() async throws {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextThrowableError = TestingError.error

      await viewModel.send(.submit(oldViewState, false))

      XCTAssertEqual(router.calledPresentationResultState, .error)
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testSubmit_useCaseThrowsInvalidCredential_navigatesToInvalidCredential() async throws {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextThrowableError = BITPresentation.SubmitPresentationError.invalidCredential

      await viewModel.send(.submit(oldViewState, false))

      XCTAssertEqual(router.calledPresentationResultState, .invalidCredential(claims: context.selectedCredential!.requestedClusteredClaims.flatMap(\.claims)))
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testSubmitPresentation_useCaseThrowsProcessClosed_navigatesToCancelled() async throws {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextThrowableError = BITPresentation.SubmitPresentationError.processClosed

      await viewModel.send(.submit(oldViewState, false))

      XCTAssertEqual(router.calledPresentationResultState, .cancelled)
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testSubmitPresentation_useCaseThrowsUserNotLoggedIn_navigatesToLogin() async throws {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextThrowableError = UserSessionError.notLoggedIn

      await viewModel.send(.submit(oldViewState, false))

      XCTAssertFalse(router.didCallLogin)
      if case .result(let viewState) = viewModel.state {
        XCTAssertTrue(viewModel.isSessionTimeoutPresented)
        XCTAssertEqual(viewState, oldViewState)
        XCTAssertFalse(viewModel.isUnknownVerifierAlertShown)
        XCTAssertFalse(declinePresentationUseCase.callAsFunctionContextCalled)
        return
      }
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testDeny_success_navigatesToDeny() async throws {
    await viewModel.send(.deny)
    try await viewModel.denyTask?.value

    XCTAssertEqual(router.calledPresentationResultState, .deny)
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextCallsCount, 1)
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextReceivedContext?.requestObject, context.requestObject)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  func testDeny_useCaseThrowsError_navigatesToDeny() async throws {
    declinePresentationUseCase.callAsFunctionContextThrowableError = TestingError.error

    await viewModel.send(.deny)
    try await viewModel.denyTask?.value

    XCTAssertEqual(router.calledPresentationResultState, .deny)
  }

  func testLogin_success_navigatesToLogin() async throws {
    await viewModel.send(.login)

    XCTAssertTrue(router.didCallLogin)
    XCTAssertFalse(declinePresentationUseCase.callAsFunctionContextCalled)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  // MARK: Private

  private let colorSchemeMock = "colorScheme"

  private var viewModel: PresentationRequestReviewViewModel!
  private let context: PresentationRequestContext = .Mock.vcSdJwtWithIdentityTrust
  private var submitPresentationUseCase: SubmitPresentationUseCaseProtocolSpy!
  private var declinePresentationUseCase: DeclinePresentationUseCaseProtocolSpy!
  private var router: MockPresentationRouter!

  private func registerMocks() {
    submitPresentationUseCase = SubmitPresentationUseCaseProtocolSpy()
    declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()
    Container.shared.submitPresentationUseCase.register { self.submitPresentationUseCase }
    Container.shared.declinePresentationUseCase.register { self.declinePresentationUseCase }

    router = MockPresentationRouter()
  }
}
