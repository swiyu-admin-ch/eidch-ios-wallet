// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - PresentationRequestReviewViewModelTests

@MainActor
class PresentationRequestReviewViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()

    viewModel = PresentationRequestReviewViewModel(context: context)
    viewModel.updateCredential(with: colorSchemeMock)
  }

  @MainActor
  func testInit_loadingWithoutAlert() {
    viewModel = PresentationRequestReviewViewModel(context: context)

    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.isUnknownVerifierAlertShown, false)
  }

  @MainActor
  func testUpdateCredential_loading_updatesStateToResult() {
    viewModel = PresentationRequestReviewViewModel(context: context)
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

  func testSubmit_Success_stateIsProcessingAndNavigatesToSuccess() async {
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, false))

      if case .processing(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.credential, oldViewState.credential)
        XCTAssertEqual(viewState.verifierDisplay, oldViewState.verifierDisplay)
        XCTAssertEqual(viewState.isMessagePresented, false)
        switch viewModel.destination {
        case .resultState(let state, let destinationContext):
          XCTAssertEqual(state, .success)
          XCTAssertEqual(destinationContext, context)
        default:
          XCTFail("Expected result state destination")
        }
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_Success_passesArguments() async {
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

  func testSubmit_progressEvent_updatesProcessingProgress() async {
    if case .result(let oldViewState) = viewModel.state {
      let progress = 0.42
      submitPresentationUseCase.executeContextReturnValue = .just(.progress(0.42), .success)

      await viewModel.send(.submit(oldViewState, false))

      if case .processing(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.progress, progress)
        switch viewModel.destination {
        case .resultState(let state, let destinationContext):
          XCTAssertEqual(state, .success)
          XCTAssertEqual(destinationContext, context)
        default:
          XCTFail("Expected result state destination")
        }
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_unknownTrustIdentity_showsAlert() async {
    viewModel = PresentationRequestReviewViewModel(context: .Mock.vcSdJwtWithUnknownIdentityTrust)
    viewModel.updateCredential(with: colorSchemeMock)
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, false))

      if case .result = viewModel.state {
        XCTAssertTrue(viewModel.isUnknownVerifierAlertShown)
        XCTAssertNil(viewModel.destination)
        XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
        XCTAssertFalse(declinePresentationUseCase.callAsFunctionContextCalled)
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_unknownTrustIdentityWithForce_navigatesToSuccess() async {
    viewModel = PresentationRequestReviewViewModel(context: .Mock.vcSdJwtWithUnknownIdentityTrust)
    viewModel.updateCredential(with: colorSchemeMock)
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, true))

      if case .processing(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.credential, oldViewState.credential)
        XCTAssertEqual(viewState.verifierDisplay, oldViewState.verifierDisplay)
        XCTAssertEqual(viewState.isMessagePresented, false)
        switch viewModel.destination {
        case .resultState(let state, let destinationContext):
          XCTAssertEqual(state, .success)
          XCTAssertEqual(destinationContext, .Mock.vcSdJwtWithUnknownIdentityTrust)
        default:
          XCTFail("Expected result state destination")
        }
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_useCaseThrowsError_navigatesToError() async {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextReturnValue = .fail(TestingError.error)

      await viewModel.send(.submit(oldViewState, false))

      switch viewModel.destination {
      case .resultState(let state, let destinationContext):
        XCTAssertEqual(state, .error)
        XCTAssertEqual(destinationContext, context)
      default:
        XCTFail("Expected result state destination")
      }
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testSubmit_useCaseThrowsInvalidCredential_navigatesToInvalidCredential() async {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextReturnValue = .fail(PresentationError.invalidCredential)

      await viewModel.send(.submit(oldViewState, false))

      switch viewModel.destination {
      case .resultState(let state, let destinationContext):
        XCTAssertEqual(state, .invalidCredential)
        XCTAssertEqual(destinationContext, context)
      default:
        XCTFail("Expected result state destination")
      }
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testSubmit_useCaseThrowsVerifierError_navigatesToErrorView() async throws {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextReturnValue = .fail(
        PresentationError.submitPresentationError("invalid_credential", nil))

      await viewModel.send(.submit(oldViewState, false))

      switch viewModel.destination {
      case .error(let dataset):
        XCTAssertEqual(dataset, try XCTUnwrap(PresentationError.submitPresentationError("invalid_credential", nil).errorDataset))
      default:
        XCTFail("Expected error destination")
      }
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testSubmitPresentation_useCaseThrowsUserNotLoggedIn_navigatesToErrorResult() async {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextReturnValue = .fail(UserSessionError.notLoggedIn)

      await viewModel.send(.submit(oldViewState, false))

      if case .result(let viewState) = viewModel.state {
        XCTAssertEqual(viewState, oldViewState)
        XCTAssertFalse(viewModel.isUnknownVerifierAlertShown)
        XCTAssertFalse(declinePresentationUseCase.callAsFunctionContextCalled)
      } else {
        XCTFail("Wrong state: \(viewModel.state)")
      }

      if case .resultState(let state, let destinationContext) = viewModel.destination {
        XCTAssertEqual(state, .error)
        XCTAssertEqual(destinationContext, context)
      }
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testDeny_success_navigatesToDeny() async throws {
    await viewModel.send(.deny)
    try await viewModel.denyTask?.value

    switch viewModel.destination {
    case .resultState(let state, let destinationContext):
      XCTAssertEqual(state, .deny)
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected result state destination")
    }
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextCallsCount, 1)
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextReceivedContext?.requestObject, context.requestObject)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  func testDeny_useCaseThrowsError_navigatesToDeny() async throws {
    declinePresentationUseCase.callAsFunctionContextThrowableError = TestingError.error

    await viewModel.send(.deny)
    try await viewModel.denyTask?.value

    switch viewModel.destination {
    case .resultState(let state, let destinationContext):
      XCTAssertEqual(state, .deny)
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected result state destination")
    }
  }

  // MARK: Private

  private let colorSchemeMock = "colorScheme"

  private var viewModel: PresentationRequestReviewViewModel!
  private let context: PresentationRequestContext = .Mock.vcSdJwtWithIdentityTrust
  private var submitPresentationUseCase: SubmitPresentationUseCaseProtocolSpy!
  private var declinePresentationUseCase: DeclinePresentationUseCaseProtocolSpy!

  private func registerMocks() {
    submitPresentationUseCase = SubmitPresentationUseCaseProtocolSpy()
    declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()
    Container.shared.submitPresentationUseCase.register { @MainActor in self.submitPresentationUseCase }
    Container.shared.declinePresentationUseCase.register { @MainActor in self.declinePresentationUseCase }

    submitPresentationUseCase.executeContextReturnValue = .just(.success)
  }
}
