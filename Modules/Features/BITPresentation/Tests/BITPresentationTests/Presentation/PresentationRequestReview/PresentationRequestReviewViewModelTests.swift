// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITNetworking
@testable import BITNonCompliance
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - PresentationRequestReviewViewModelTests

@MainActor
class PresentationRequestReviewViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    Container.shared.reset()
    registerMocks()

    context = makeContext()
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

  @MainActor
  func testOnAppear_pvaTSValid_justRuns() async {
    await viewModel.send(.onAppear)

    XCTAssertNil(viewModel.destination)
  }

  @MainActor
  func testOnAppear_unauthorizedVerification_navigatesToError() async {
    validateVerificationAuthorizationTrustStatementUseCase.callAsFunctionRequestObjectRequestedClaimsThrowableError =
      ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification()

    await viewModel.send(.onAppear)

    guard case .error(_, nil) = viewModel.destination else {
      return XCTFail("Expected error destination")
    }
  }

  @MainActor
  func testOnAppear_unauthorizedVerificationWithRedirect_navigatesToErrorWithPresentationResponse() async {
    let presentationResponse = PresentationResponse(redirectUri: redirectUri)
    validateVerificationAuthorizationTrustStatementUseCase.callAsFunctionRequestObjectRequestedClaimsThrowableError =
      ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification(
        presentationResponse: presentationResponse)

    await viewModel.send(.onAppear)

    guard case .error(_, let destinationResponse) = viewModel.destination else {
      return XCTFail("Expected error destination")
    }
    XCTAssertEqual(destinationResponse, presentationResponse)
  }

  @MainActor
  func testOnAppear_invalidRedirect_navigatesToRedirectErrorView() async {
    validateVerificationAuthorizationTrustStatementUseCase.callAsFunctionRequestObjectRequestedClaimsThrowableError =
      PresentationResponseValidationError.invalidRedirectUri

    await viewModel.send(.onAppear)

    guard case .error(.invalidRedirectUri, nil) = viewModel.destination else {
      return XCTFail("Expected error destination")
    }
  }

  @MainActor
  func testOnAppear_pvaTSValidatorThrowsError_navigatesToError() async {
    validateVerificationAuthorizationTrustStatementUseCase.callAsFunctionRequestObjectRequestedClaimsThrowableError = TestingError.error

    await viewModel.send(.onAppear)

    XCTAssertEqual(viewModel.destination, .resultState(.error, context))
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
          XCTAssertEqual(state, .dataTransmitted(nil))
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

  func testSubmit_redirect_navigatesToDataTransmitted() async {
    let presentationResponse = PresentationResponse(redirectUri: redirectUri)
    submitPresentationUseCase.executeContextReturnValue = .just(.success(presentationResponse))
    guard case .result(let oldViewState) = viewModel.state else {
      return XCTFail("Wrong state: \(viewModel.state)")
    }

    await viewModel.send(.submit(oldViewState, false))

    guard case .resultState(let state, let destinationContext) = viewModel.destination else {
      return XCTFail("Expected result state destination")
    }
    XCTAssertEqual(state, .dataTransmitted(presentationResponse))
    XCTAssertEqual(destinationContext, context)
  }

  func testSubmit_progressEvent_updatesProcessingProgress() async {
    if case .result(let oldViewState) = viewModel.state {
      let progress = 0.42
      submitPresentationUseCase.executeContextReturnValue = .just(.progress(0.42), .success(nil))

      await viewModel.send(.submit(oldViewState, false))

      if case .processing(let viewState) = viewModel.state {
        XCTAssertEqual(viewState.progress, progress)
        switch viewModel.destination {
        case .resultState(let state, let destinationContext):
          XCTAssertEqual(state, .dataTransmitted(nil))
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
          XCTAssertEqual(state, .dataTransmitted(nil))
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

  func testSubmit_nonCompliantActor_showsAlert() async {
    context = makeContext(actorCompliance: .notCompliant(nil))
    viewModel = PresentationRequestReviewViewModel(context: context)
    viewModel.updateCredential(with: colorSchemeMock)

    if case .result(let oldViewState) = viewModel.state {
      await viewModel.send(.submit(oldViewState, false))

      if case .result = viewModel.state {
        XCTAssertEqual(viewModel.alert, .nonCompliantActor)
        XCTAssertNil(viewModel.destination)
        XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
        return
      }
    }

    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testSubmit_nonCompliantActorWithForce_submits() async {
    context = makeContext(actorCompliance: .notCompliant(nil))
    viewModel = PresentationRequestReviewViewModel(context: context)
    viewModel.updateCredential(with: colorSchemeMock)

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

  func testSubmit_unregisteredRequest_showsAlert() async {
    context = makeContext(hasVerifiedQuery: false)
    viewModel = PresentationRequestReviewViewModel(context: context)
    viewModel.updateCredential(with: colorSchemeMock)

    if case .result(let oldViewState) = viewModel.state {
      await viewModel.send(.submit(oldViewState, false))

      if case .result = viewModel.state {
        XCTAssertEqual(viewModel.alert, .unregisteredRequest)
        XCTAssertNil(viewModel.destination)
        XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
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
        XCTAssertEqual(state, .dataTransmitted(nil))
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
      XCTAssertEqual(state, .deny(nil))
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected result state destination")
    }
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextCallsCount, 1)
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextReceivedContext?.requestObject, context.requestObject)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  func testDeny_responseWithRedirect_navigatesToDeny() async {
    let presentationResponse = PresentationResponse(redirectUri: redirectUri)
    declinePresentationUseCase.callAsFunctionContextReturnValue = presentationResponse

    await viewModel.send(.deny)

    guard case .resultState(let state, let destinationContext) = viewModel.destination else {
      return XCTFail("Expected result state destination")
    }
    XCTAssertEqual(state, .deny(presentationResponse))
    XCTAssertEqual(destinationContext, context)
  }

  func testDeny_invalidRedirect_navigatesToRedirectErrorView() async {
    declinePresentationUseCase.callAsFunctionContextThrowableError = PresentationResponseValidationError.invalidRedirectUri

    await viewModel.send(.deny)

    XCTAssertEqual(viewModel.destination, .error(.invalidRedirectUri, nil))
  }

  func testDeny_useCaseThrowsError_navigatesToDeny() async throws {
    declinePresentationUseCase.callAsFunctionContextThrowableError = TestingError.error

    await viewModel.send(.deny)
    try await viewModel.denyTask?.value

    switch viewModel.destination {
    case .resultState(let state, let destinationContext):
      XCTAssertEqual(state, .deny(nil))
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected result state destination")
    }
  }

  // MARK: Private

  private let colorSchemeMock = "colorScheme"
  private let redirectUri = URL(string: "https://verifier.ch")!

  private var viewModel: PresentationRequestReviewViewModel!
  private var context: PresentationRequestContext!
  private var submitPresentationUseCase: SubmitPresentationUseCaseProtocolSpy!
  private var declinePresentationUseCase: DeclinePresentationUseCaseProtocolSpy!
  private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocolSpy!
  private var validateVerificationAuthorizationTrustStatementUseCase: ValidateVerificationAuthorizationTrustStatementUseCaseProtocolSpy!

  private func makeContext(hasVerifiedQuery: Bool = true, actorCompliance: ActorCompliance = .compliant) -> PresentationRequestContext {
    let jws = hasVerifiedQuery ? RequestObjectJWS.Mock.sample : RequestObjectJWS.Mock.identityTrustedWithoutVerifiedQuery
    return PresentationRequestContext(
      requestObjectJWS: jws,
      compatibleCredentials: [CompatibleCredential.Mock.BIT],
      trustInformation: .Mock.trustedIdentity,
      actorCompliance: actorCompliance)
  }

  private func registerMocks() {
    submitPresentationUseCase = SubmitPresentationUseCaseProtocolSpy()
    declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()
    selectCredentialBundleItemUseCase = SelectCredentialBundleItemUseCaseProtocolSpy()
    validateVerificationAuthorizationTrustStatementUseCase = ValidateVerificationAuthorizationTrustStatementUseCaseProtocolSpy()
    selectCredentialBundleItemUseCase.callAsFunctionClosure = { credential in
      guard let first = credential.bundleItems.first else { throw CredentialError.noBundleItem }
      return first
    }
    Container.shared.submitPresentationUseCase.register { @MainActor in self.submitPresentationUseCase }
    Container.shared.declinePresentationUseCase.register { @MainActor in self.declinePresentationUseCase }
    Container.shared.selectCredentialBundleItemUseCase.register { @MainActor in self.selectCredentialBundleItemUseCase }
    Container.shared.validateVerificationAuthorizationTrustStatementUseCase.register { @MainActor in self.validateVerificationAuthorizationTrustStatementUseCase }

    submitPresentationUseCase.executeContextReturnValue = .just(.success(nil))
  }
}
