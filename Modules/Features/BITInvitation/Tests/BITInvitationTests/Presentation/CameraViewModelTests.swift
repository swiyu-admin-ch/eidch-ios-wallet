import BITNetworking
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAnalytics
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITInvitation
@testable import BITL10n
@testable import BITOpenID
@testable import BITPresentation
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - CameraViewModelTests

@MainActor
final class CameraViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    let validateCredentialOfferInvitationUrlUseCase = validateCredentialOfferInvitationUrlUseCase
    let fetchPresentationRequestUseCase = fetchPresentationRequestUseCase
    let checkInvitationTypeUseCase = checkInvitationTypeUseCase
    let getCompatibleCredentialsUseCase = getCompatibleCredentialsUseCase
    let fetchCredentialUseCase = fetchCredentialUseCase
    let getCredentialsCountUseCase = getCredentialsCountUseCase
    let saveDeferredCredentialUseCase = saveDeferredCredentialUseCase

    Container.shared.validateCredentialOfferInvitationUrlUseCase.register { @MainActor in validateCredentialOfferInvitationUrlUseCase }
    Container.shared.fetchPresentationRequestUseCase.register { @MainActor in fetchPresentationRequestUseCase }
    Container.shared.checkInvitationTypeUseCase.register { @MainActor in checkInvitationTypeUseCase }
    Container.shared.getCompatibleCredentialsUseCase.register { @MainActor in getCompatibleCredentialsUseCase }
    Container.shared.fetchCredentialUseCase.register { @MainActor in fetchCredentialUseCase }
    Container.shared.getCredentialsCountUseCase.register { @MainActor in getCredentialsCountUseCase }
    Container.shared.saveDeferredCredentialUseCase.register { @MainActor in saveDeferredCredentialUseCase }

    analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    self.analytics = analytics
    analytics.register(analyticsProvider)

    Container.shared.analytics.register { @MainActor in analytics }

    let accessibilityFeedback = CameraAccessibilityFeedbackProtocolSpy()
    self.accessibilityFeedback = accessibilityFeedback
    Container.shared.accessibilityFeedback.register { @MainActor in accessibilityFeedback }
    viewModel = createViewModel(mode: .qr)
    viewModel.cameraManager = cameraManager
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testWithInitialData() {
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.notificationState)
    XCTAssertNil(viewModel.error)
    XCTAssertTrue(viewModel.isScanEnabled)
  }

  // MARK: - Issuing

  func testValidateCredentialOfferSuccess() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    let credential = VerifiableCredential.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = credential

    await viewModel.setMetadataUrl(url)

    switch viewModel.destination {
    case .offer(let destinationCredential):
      XCTAssertEqual(destinationCredential.id, credential.id)
    default:
      XCTFail("Expected credential offer destination")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertNil(viewModel.notificationState)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)

    XCTAssertFalse(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)

    assertSetMetadataUrlAccessibilityFeedback()
    XCTAssertEqual(accessibilityFeedback.announceCameraDidStopRunningCallsCount, 1)
  }

  func testValidateCredentialOffer_deferredCredential_saveCredential() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = DeferredCredential.Mock.sample

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.onDismiss)
    XCTAssertEqual(saveDeferredCredentialUseCase.executeForCallsCount, 1)
    XCTAssertEqual(saveDeferredCredentialUseCase.executeForReceivedDeferredCredential, DeferredCredential.Mock.sample)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testValidateCredentialOfferSuccess_deeplink() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    let credential = VerifiableCredential.Mock.sample

    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = credential

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    switch viewModel.destination {
    case .offer(let destinationCredential):
      XCTAssertEqual(destinationCredential.id, credential.id)
    default:
      XCTFail("Expected credential offer destination")
    }
    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(1, fetchCredentialUseCase.executeFromCallsCount)
    XCTAssertFalse(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)
    XCTAssertFalse(cameraManager.configureCalled)
    XCTAssertFalse(cameraManager.startCalled)
    XCTAssertFalse(getCredentialsCountUseCase.callAsFunctionCalled)
  }

  func testValidateCredentialOfferFailure() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeThrowableError = ValidateCredentialOfferInvitationUrlError.unexpectedScheme

    viewModel.isTorchEnabled = true

    await viewModel.setMetadataUrl(url)

    if case .failure(let error as InvitationError) = viewModel.notificationState {
      XCTAssertEqual(error, .invalidQRCode())
    } else {
      XCTFail("Expected InvitationError.invalidQRCode")
    }
    XCTAssertTrue(viewModel.isTorchEnabled)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
    XCTAssertFalse(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testValidateCredentialOfferVerificationFailure() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromThrowableError = FetchAnyVerifiableCredentialError.validationFailed

    viewModel.isTorchEnabled = true

    await viewModel.setMetadataUrl(url)

    if case .failure(let error as InvitationError) = viewModel.notificationState {
      XCTAssertEqual(error, .validationFailed)
    } else {
      XCTFail("Expected InvitationError.validationFailed")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(fetchCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertFalse(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testValidateCredentialOfferUnknownIssuer() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromThrowableError = FetchAnyVerifiableCredentialError.unknownIssuer

    await viewModel.setMetadataUrl(url)

    if case .failure(let error as InvitationError) = viewModel.notificationState {
      XCTAssertEqual(error, .unknownIssuer)
    } else {
      XCTFail("Expected InvitationError.unknownIssuer")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)
    XCTAssertEqual(url, checkInvitationTypeUseCase.executeUrlReceivedUrl)

    XCTAssertFalse(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testValidateCredentialOfferUnverifiedActor_showsErrorView() async throws {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample
    fetchCredentialUseCase.executeFromThrowableError = GovernanceError.unverifiedActor

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    XCTAssertNil(viewModel.notificationState)
    XCTAssertEqual(viewModel.error as? InvitationError, .unverifiedActor)

    switch viewModel.destination {
    case .deeplinkError(let dataset, _, _):
      XCTAssertEqual(dataset, try XCTUnwrap(InvitationError.unverifiedActor.errorDataset))
    default:
      XCTFail("Expected deeplink error destination")
    }
  }

  func testValidateCredentialOfferUnknownRegistry_showsErrorView() async throws {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample
    fetchCredentialUseCase.executeFromThrowableError = GovernanceError.unknownRegistry

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    XCTAssertNil(viewModel.notificationState)
    XCTAssertEqual(viewModel.error as? InvitationError, .unknownRegistry)

    switch viewModel.destination {
    case .deeplinkError(let dataset, _, _):
      XCTAssertEqual(dataset, try XCTUnwrap(InvitationError.unknownRegistry.errorDataset))
    default:
      XCTFail("Expected deeplink error destination")
    }
  }

  func testValidateCredentialOfferUnauthorizedIssuance_showsErrorView() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample
    fetchCredentialUseCase.executeFromThrowableError = GovernanceError.unauthorizedIssuance

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    XCTAssertNil(viewModel.notificationState)
    XCTAssertEqual(viewModel.error as? InvitationError, .unauthorizedIssuance)

    switch viewModel.destination {
    case .deeplinkError(let dataset, _, _):
      XCTAssertEqual(dataset, .governanceError(
        rawErrorCode: GovernanceError.unauthorizedIssuance.rawValue,
        errorDescription: L10n.tkCredentialOfferErrorUnauthorizedIssuanceDescription))
    default:
      XCTFail("Expected deeplink error destination")
    }
  }

  func testFetchCredential_userNotLoggedIn_showsErrorPopup() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample
    fetchCredentialUseCase.executeFromThrowableError = UserSessionError.notLoggedIn

    await viewModel.setMetadataUrl(url)

    if case .failure(let error as InvitationError) = viewModel.notificationState {
      XCTAssertEqual(error, .invalidQRCode())
    } else {
      XCTFail("Expected InvitationError.invalidQRCode")
    }
    XCTAssertNil(viewModel.destination)
    XCTAssertFalse(viewModel.isTorchEnabled)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testFetchCredential_invalidClient_showsErrorView() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample
    fetchCredentialUseCase.executeFromThrowableError = OpenIdRepositoryError.invalidClient("invalid_client")

    await viewModel.setMetadataUrl(url)

    XCTAssertEqual(
      viewModel.error as? InvitationError,
      .oAuth(.invalidClient("invalid_client")))
    switch viewModel.destination {
    case .error:
      break
    default:
      XCTFail("Expected error destination")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertNil(viewModel.notificationState)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testFetchCredential_temporarilyUnavailableErrorInDeeplink_showsPushedErrorView() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample
    fetchCredentialUseCase.executeFromThrowableError = OpenIdRepositoryError.unsupportedGrantType("unsupported_grant_type")

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    XCTAssertEqual(viewModel.error as? InvitationError, .oAuth(.unsupportedGrantType("unsupported_grant_type")))
    switch viewModel.destination {
    case .deeplinkError:
      break
    default:
      XCTFail("Expected error destination")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertNil(viewModel.notificationState)
  }

  // MARK: - Presentation

  func testValidatePresentationWithOneCredentialSuccess() async {
    let bundle = PresentationRequestContext.Mock.vcSdJwtSample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlReturnValue = bundle

    await viewModel.setMetadataUrl(url)

    switch viewModel.destination {
    case .external(.presentation(let destinationContext)):
      XCTAssertEqual(destinationContext, bundle)
    default:
      XCTFail("Expected presentation destination")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertNil(viewModel.notificationState)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertEqual(1, fetchPresentationRequestUseCase.callAsFunctionUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)

    assertSetMetadataUrlAccessibilityFeedback()
    XCTAssertEqual(accessibilityFeedback.announceCameraDidStopRunningCallsCount, 1)
  }

  func testValidatePresentationWithMultipleCredentialSuccess() async {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlReturnValue = context

    await viewModel.setMetadataUrl(url)

    switch viewModel.destination {
    case .external(.presentation(let destinationContext)):
      XCTAssertEqual(destinationContext, context)
    default:
      XCTFail("Expected presentation destination")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertNil(viewModel.notificationState)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertEqual(1, fetchPresentationRequestUseCase.callAsFunctionUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)

    assertSetMetadataUrlAccessibilityFeedback()
    XCTAssertEqual(accessibilityFeedback.announceCameraDidStopRunningCallsCount, 1)
  }

  func testValidatePresentationFailure() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlThrowableError = TestingError.error

    await viewModel.setMetadataUrl(url)

    switch viewModel.notificationState {
    case .failure: break
    default: XCTFail("Expected failure bannerState")
    }

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertEqual(1, fetchPresentationRequestUseCase.callAsFunctionUrlCallsCount)

    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)
    XCTAssertEqual(0, getCompatibleCredentialsUseCase.callAsFunctionUsingCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testValidatePresentationInvalidRedirectUri_showsRedirectErrorView() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlThrowableError = PresentationResponseValidationError.invalidRedirectUri

    await viewModel.setMetadataUrl(url)

    XCTAssertNil(viewModel.notificationState)
    XCTAssertEqual(viewModel.error as? InvitationError, .invalidRedirectUri)
    guard case .error(let dataset, _, _) = viewModel.destination else {
      return XCTFail("Expected error destination")
    }
    XCTAssertEqual(dataset, .invalidRedirectUri)
  }

  func testValidatePresentationTransactionDataNotSupported_showsPushedErrorView() async throws {
    let presentationResponse = PresentationResponse(redirectUri: URL(string: "https://verifier.ch"))
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlThrowableError = FetchPresentationRequestUseCaseError.transactionDataNotSupported(
      "invalid_request",
      presentationResponse: presentationResponse)

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    XCTAssertNil(viewModel.notificationState)
    XCTAssertEqual(viewModel.error as? InvitationError, .transactionDataNotSupported("invalid_request"))

    switch viewModel.destination {
    case .deeplinkError(let dataset, _, let forwardedResponse):
      XCTAssertEqual(dataset, try XCTUnwrap(InvitationError.transactionDataNotSupported("invalid_request").errorDataset))
      XCTAssertEqual(forwardedResponse, presentationResponse)
    default:
      XCTFail("Expected deeplink error destination")
    }
  }

  func testValidatePresentationUnverifiedActor_showsErrorView() async throws {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlThrowableError = FetchPresentationRequestUseCaseError.unverifiedActor()

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    let expectedError = InvitationError.unverifiedActor
    XCTAssertNil(viewModel.notificationState)
    XCTAssertEqual(viewModel.error as? InvitationError, expectedError)

    switch viewModel.destination {
    case .deeplinkError(let dataset, _, let presentationResponse):
      XCTAssertEqual(dataset, try XCTUnwrap(expectedError.errorDataset))
      XCTAssertNil(presentationResponse)
    default:
      XCTFail("Expected deeplink error destination")
    }
  }

  func testValidatePresentationUnknownRegistry_showsErrorView() async throws {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlThrowableError = FetchPresentationRequestUseCaseError.unknownRegistry()

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    let expectedError = InvitationError.unknownRegistry
    XCTAssertNil(viewModel.notificationState)
    XCTAssertEqual(viewModel.error as? InvitationError, expectedError)

    switch viewModel.destination {
    case .deeplinkError(let dataset, _, _):
      XCTAssertEqual(dataset, try XCTUnwrap(expectedError.errorDataset))
    default:
      XCTFail("Expected deeplink error destination")
    }
  }

  func testFetchCredentialFailed_networkError() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample

    fetchCredentialUseCase.executeFromThrowableError = NetworkError(status: .noConnection)

    await viewModel.setMetadataUrl(url)

    assertsNoInternetConnexion()
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testSubmitPresentationFailed_networkError() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.callAsFunctionUrlThrowableError = NetworkError(status: .noConnection)

    await viewModel.setMetadataUrl(url)

    if case .failure(let error as InvitationError) = viewModel.notificationState {
      XCTAssertEqual(error, .noConnection)
    } else {
      XCTFail("Expected InvitationError.noConnection")
    }
    XCTAssertNil(viewModel.destination)
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertTrue(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)
    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testCheckInvitationTypeFailed_wrongScheme() async {
    checkInvitationTypeUseCase.executeUrlThrowableError = CheckInvitationTypeError.wrongScheme

    await viewModel.setMetadataUrl(url)

    if case .failure(let error as InvitationError) = viewModel.notificationState {
      XCTAssertEqual(error, .invalidQRCode())
    } else {
      XCTFail("Expected InvitationError.invalidQRCode")
    }
    XCTAssertEqual(analyticsProvider.logCounter, 0)

    assertSetMetadataUrlAccessibilityFeedback()
  }

  func testCloseErrorView() {
    viewModel.notificationState = .failure(error: TestingError.error)

    viewModel.closeErrorView()

    XCTAssertNil(viewModel.error)
    XCTAssertNil(viewModel.notificationState)
    XCTAssertNil(viewModel.destination)
  }

  func testCloseTipView() {
    viewModel.closeTipView()

    XCTAssertNil(viewModel.notificationState)
  }

  func testToggleTorch() {
    let initialState = viewModel.isTorchEnabled
    viewModel.toggleTorch()
    XCTAssertEqual(viewModel.isTorchEnabled, !initialState)
  }

  func testOnAppearWithCredentials() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 2

    await viewModel.onAppear()

    XCTAssertNil(viewModel.notificationState)
  }

  func testOnCameraPermissionChangeWithoutCredentials() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 0

    await viewModel.onCameraPermissionChange(.authorized)

    assertOnAppearWhenCameraIsReady()
    XCTAssertEqual(viewModel.notificationState, .tip)
  }

  func testOnCameraPermissionChangeWithError() async {
    getCredentialsCountUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.onCameraPermissionChange(.authorized)

    assertOnAppearWhenCameraIsReady()
    XCTAssertEqual(viewModel.notificationState, .tip)
  }

  func test_onCameraPermissionChange_toAuthorized_withoutCredentials() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 0

    await viewModel.onCameraPermissionChange(.authorized)

    assertOnAppearWhenCameraIsReady()
    XCTAssertEqual(viewModel.notificationState, .tip)
  }

  func test_onCameraPermissionChange_toAuthorized_withCredentials() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 1

    await viewModel.onCameraPermissionChange(.authorized)

    assertOnAppearWhenCameraIsReady()
    XCTAssertNil(viewModel.notificationState)
  }

  func test_onCameraPermissionChange_toDenied() async {
    getCredentialsCountUseCase.callAsFunctionReturnValue = 0

    await viewModel.onCameraPermissionChange(.denied)

    XCTAssertFalse(accessibilityFeedback.announceCameraDidStartRunningCalled)
  }

  // MARK: Private

  // swiftlint:disable implicitly_unwrapped_optional force_unwrapping
  private let validateCredentialOfferInvitationUrlUseCase = ValidateCredentialOfferInvitationUrlUseCaseProtocolSpy()
  private let fetchPresentationRequestUseCase = FetchPresentationRequestUseCaseProtocolSpy()
  private let checkInvitationTypeUseCase = CheckInvitationTypeUseCaseProtocolSpy()
  private let getCompatibleCredentialsUseCase = GetCompatibleCredentialsUseCaseProtocolSpy()
  private let fetchCredentialUseCase = FetchCredentialUseCaseProtocolSpy()
  private let getCredentialsCountUseCase = GetCredentialsCountUseCaseProtocolSpy()
  private let saveDeferredCredentialUseCase = SaveDeferredCredentialUseCaseProtocolSpy()
  private var accessibilityFeedback: CameraAccessibilityFeedbackProtocolSpy!
  private let cameraManager = MockCameraManager()
  private var viewModel: CameraViewModel!
  private let url = URL(string: "openid-credential-offer://url")!

  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!
  // swiftlint:enable implicitly_unwrapped_optional force_unwrapping
}

extension CameraViewModelTests {

  private enum InvitationMode: Equatable {
    case deeplink(url: URL)
    case qr
  }

  private func createViewModel(mode: InvitationMode = .qr) -> CameraViewModel {
    switch mode {
    case .qr: CameraViewModel()
    case .deeplink(let url): CameraViewModel(url: url)
    }
  }

  private func assertsNoInternetConnexion() {
    if case .failure(let error as InvitationError) = viewModel.notificationState {
      XCTAssertEqual(error, .noConnection)
    } else {
      XCTFail("Expected InvitationError.noConnection")
    }
    XCTAssertNil(viewModel.destination)
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)
    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertFalse(fetchPresentationRequestUseCase.callAsFunctionUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.callAsFunctionUsingCalled)
  }

  private func assertSetMetadataUrlAccessibilityFeedback() {
    XCTAssertEqual(accessibilityFeedback.announceQRCodeDetectedCallsCount, 1)
    XCTAssertEqual(accessibilityFeedback.stopQRCodeLoadingAnnouncementsCallsCount, 1)
  }

  private func assertOnAppearWhenCameraIsReady() {
    XCTAssertEqual(cameraManager.configureCallCount, 1)
    XCTAssertEqual(cameraManager.startCallCount, 1)
    XCTAssertEqual(accessibilityFeedback.announceCameraDidStartRunningCallsCount, 1)
    XCTAssertEqual(getCredentialsCountUseCase.callAsFunctionCallsCount, 1)
  }
}
