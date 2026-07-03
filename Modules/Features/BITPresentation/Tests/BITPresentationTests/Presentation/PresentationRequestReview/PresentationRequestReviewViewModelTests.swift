// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITNetworking
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
    XCTAssertNil(viewModel.alert)
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

  func testSubmit_Success_stateIsProcessingAndNavigatesToDataTransmitted() async {
    if case .result(let oldViewState) = viewModel.state {

      await viewModel.send(.submit(oldViewState, false))

      if case .processing(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.credential, oldViewState.credential)
        XCTAssertEqual(viewState.verifierDisplay, oldViewState.verifierDisplay)
        XCTAssertEqual(viewState.isMessagePresented, false)
        switch viewModel.destination {
        case .resultState(let state, let destinationContext):
          XCTAssertEqual(state, .dataTransmitted)
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
          XCTAssertEqual(state, .dataTransmitted)
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
        XCTAssertEqual(viewModel.alert, .unknownVerifier)
        XCTAssertNil(viewModel.destination)
        XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
        XCTAssertFalse(declinePresentationUseCase.callAsFunctionContextCalled)
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_unknownTrustIdentityWithForce_navigatesToDataTransmitted() async {
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
          XCTAssertEqual(state, .dataTransmitted)
          XCTAssertEqual(destinationContext, .Mock.vcSdJwtWithUnknownIdentityTrust)
        default:
          XCTFail("Expected result state destination")
        }
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_businessExpiredCredential_showsAlert() async {
    selectCredentialBundleItemUseCase.callAsFunctionClosure = { credential in
      guard var bundleItem = credential.bundleItems.first else { throw CredentialError.noBundleItem }
      bundleItem.status = .businessExpired
      return bundleItem
    }

    if case .result(let oldViewState) = viewModel.state {
      await viewModel.send(.submit(oldViewState, false))

      if case .result = viewModel.state {
        XCTAssertEqual(viewModel.alert, .businessExpiredCredential)
        XCTAssertNil(viewModel.destination)
        XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
        return
      }
    }

    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_businessExpiredCredentialWithForce_submits() async {
    selectCredentialBundleItemUseCase.callAsFunctionClosure = { credential in
      guard var bundleItem = credential.bundleItems.first else { throw CredentialError.noBundleItem }
      bundleItem.status = .businessExpired
      return bundleItem
    }

    if case .result(let oldViewState) = viewModel.state {
      await viewModel.send(.submit(oldViewState, true))

      if case .processing = viewModel.state {
        XCTAssertNil(viewModel.alert)
        XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
        return
      }
    }

    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_suspendedCredential_showsAlert() async {
    selectCredentialBundleItemUseCase.callAsFunctionClosure = { credential in
      guard var bundleItem = credential.bundleItems.first else { throw CredentialError.noBundleItem }
      bundleItem.status = .suspended
      return bundleItem
    }

    if case .result(let oldViewState) = viewModel.state {
      await viewModel.send(.submit(oldViewState, false))

      if case .result = viewModel.state {
        XCTAssertEqual(viewModel.alert, .suspendedCredential)
        XCTAssertNil(viewModel.destination)
        XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
        return
      }
    }

    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_useCaseThrowsNetworkError_navigatesToDataTransmitted() async {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextReturnValue = .fail(NetworkError(status: .badRequest))

      await viewModel.send(.submit(oldViewState, false))

      switch viewModel.destination {
      case .resultState(let state, let destinationContext):
        XCTAssertEqual(state, .dataTransmitted)
        XCTAssertEqual(destinationContext, context)
      default:
        XCTFail("Expected result state destination")
      }
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testSubmit_useCaseThrowsHostnameNotFound_navigatesToError() async {
    guard case .result(let oldViewState) = viewModel.state else {
      XCTFail("Wrong state: \(viewModel.state)")
      return
    }

    submitPresentationUseCase.executeContextReturnValue = .fail(NetworkError(status: .hostnameNotFound))

    await viewModel.send(.submit(oldViewState, false))

    switch viewModel.destination {
    case .resultState(let state, let destinationContext):
      XCTAssertEqual(state, .error)
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected result state destination")
    }
  }

  func testSubmit_useCaseThrowsTimeout_navigatesToError() async {
    guard case .result(let oldViewState) = viewModel.state else {
      XCTFail("Wrong state: \(viewModel.state)")
      return
    }

    submitPresentationUseCase.executeContextReturnValue = .fail(NetworkError(status: .timeout))

    await viewModel.send(.submit(oldViewState, false))

    switch viewModel.destination {
    case .resultState(let state, let destinationContext):
      XCTAssertEqual(state, .error)
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected result state destination")
    }
  }

  func testSubmitPresentation_useCaseThrowsUserNotLoggedIn_navigatesToError() async {
    if case .result(let oldViewState) = viewModel.state {
      submitPresentationUseCase.executeContextReturnValue = .fail(UserSessionError.notLoggedIn)

      await viewModel.send(.submit(oldViewState, false))

      if case .result(let viewState) = viewModel.state {
        XCTAssertEqual(viewState, oldViewState)
        XCTAssertNil(viewModel.alert)
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
  private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocolSpy!

  private func registerMocks() {
    submitPresentationUseCase = SubmitPresentationUseCaseProtocolSpy()
    declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()
    selectCredentialBundleItemUseCase = SelectCredentialBundleItemUseCaseProtocolSpy()
    selectCredentialBundleItemUseCase.callAsFunctionClosure = { credential in
      guard let first = credential.bundleItems.first else { throw CredentialError.noBundleItem }
      return first
    }
    Container.shared.submitPresentationUseCase.register { @MainActor in self.submitPresentationUseCase }
    Container.shared.declinePresentationUseCase.register { @MainActor in self.declinePresentationUseCase }
    Container.shared.selectCredentialBundleItemUseCase.register { @MainActor in self.selectCredentialBundleItemUseCase }

    submitPresentationUseCase.executeContextReturnValue = .just(.success)
  }
}
