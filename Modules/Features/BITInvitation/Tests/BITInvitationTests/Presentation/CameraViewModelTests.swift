import BITNetworking
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAnalytics
@testable import BITAnalyticsMocks
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITInvitation
@testable import BITOpenID
@testable import BITPresentation
@testable import BITSdJWTMocks
@testable import BITTestingCore
@testable import BITVault

// MARK: - CameraViewModelTests

final class CameraViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    Container.shared.validateCredentialOfferInvitationUrlUseCase.register { self.validateCredentialOfferInvitationUrlUseCase }
    Container.shared.fetchPresentationRequestUseCase.register { self.fetchPresentationRequestUseCase }
    Container.shared.checkInvitationTypeUseCase.register { self.checkInvitationTypeUseCase }
    Container.shared.getCompatibleCredentialsUseCase.register { self.getCompatibleCredentialsUseCase }
    Container.shared.fetchCredentialUseCase.register { self.fetchCredentialUseCase }
    Container.shared.getCredentialsCountUseCase.register { self.getCredentialsCountUseCase }
    Container.shared.saveDeferredCredentialUseCase.register { self.saveDeferredCredentialUseCase }

    analyticsProvider = MockProvider()
    analytics = Analytics()
    analytics.register(analyticsProvider)

    Container.shared.analytics.register { self.analytics }

    mockRequestObject = .Mock.VcSdJwt.sample
    // MockAnyCredential
    mockCredentialWithKeyBinding = (MockAnyCredential(), nil)
    viewModel = createViewModel(mode: .qr)
  }

  @MainActor
  func testWithInitialData() {
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertFalse(viewModel.isTipPresented)
    XCTAssertFalse(viewModel.isErrorPopupPresented)
    XCTAssertNil(viewModel.error)
    XCTAssertTrue(viewModel.isScanEnabled)
  }

  // MARK: - Issuing

  @MainActor
  func testValidateCredentialOfferSuccess() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    let credential = VerifiableCredential.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = (credential, TrustInformation.Mock.trustedIdentity)

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(router.didCallCredentialOffer)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isErrorPopupPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)

    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOffer_deferredCredential_saveCredential() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = (DeferredCredential.Mock.sample, nil)

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(router.closeWithCompletionCalled)
    XCTAssertTrue(mockDelegate.didSaveCredentialCalled)
    XCTAssertEqual(saveDeferredCredentialUseCase.executeForCallsCount, 1)
    XCTAssertEqual(saveDeferredCredentialUseCase.executeForReceivedDeferredCredential, DeferredCredential.Mock.sample)
  }

  @MainActor
  func testValidateCredentialOfferSuccess_withRouter() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    let credential = VerifiableCredential.Mock.sample

    let viewModel = CameraViewModel(router: router)

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer

    fetchCredentialUseCase.executeFromReturnValue = (credential, TrustInformation.Mock.trustedIdentity)

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(router.didCallCredentialOffer)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(1, fetchCredentialUseCase.executeFromCallsCount)

    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOfferSuccess_deeplink() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    let credential = VerifiableCredential.Mock.sample

    getCredentialsCountUseCase.executeReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = (credential, TrustInformation.Mock.trustedIdentity)

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(1, fetchCredentialUseCase.executeFromCallsCount)
    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOfferFailure() async {
    getCredentialsCountUseCase.executeReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeThrowableError = ValidateCredentialOfferInvitationUrlError.unexpectedScheme

    viewModel.isTorchEnabled = true

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    if let error = viewModel.error as? InvitationError {
      XCTAssertEqual(error, .invalidQRCode)
    } else {
      XCTFail("Expected InvitationError.invalidQRCode")
    }
    XCTAssertTrue(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOfferVerificationFailure() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    getCredentialsCountUseCase.executeReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromThrowableError = FetchAnyVerifiableCredentialError.validationFailed

    viewModel.isTorchEnabled = true

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    if let error = viewModel.error as? InvitationError {
      XCTAssertEqual(error, .validationFailed)
    } else {
      XCTFail("Expected InvitationError.validationFailed")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(fetchCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOfferUnknownIssuer() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromThrowableError = FetchAnyVerifiableCredentialError.unknownIssuer

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    if let error = viewModel.error as? InvitationError {
      XCTAssertEqual(error, .unknownIssuer)
    } else {
      XCTFail("Expected InvitationError.unknownIssuer")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)
    XCTAssertEqual(url, checkInvitationTypeUseCase.executeUrlReceivedUrl)

    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testFetchCredentialExpired() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromThrowableError = FetchAnyVerifiableCredentialError.expiredInvitation

    viewModel.isTorchEnabled = true

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    if let error = viewModel.error as? InvitationError {
      XCTAssertEqual(error, .expiredInvitation)
    } else {
      XCTFail("Expected InvitationError.expiredInvitation")
    }
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)
    XCTAssertFalse(viewModel.isSessionTimeoutPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(fetchCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testFetchCredential_userNotLoggedIn_presentsSessionTimeout() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample
    fetchCredentialUseCase.executeFromThrowableError = UserSessionError.notLoggedIn

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isSessionTimeoutPresented)
    XCTAssertFalse(router.didCallLogin)
    XCTAssertFalse(viewModel.isErrorPopupPresented)
    XCTAssertNil(viewModel.error)
    XCTAssertFalse(router.didCallCredentialOffer)
    XCTAssertFalse(viewModel.isTorchEnabled)
  }

  // MARK: - Presentation

  @MainActor
  func testValidatePresentationWithOneCredentialSuccess() async {
    let bundle = PresentationRequestContext.Mock.vcSdJwtSample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.executeUrlReturnValue = bundle

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(router.didCallStartPresentation)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isErrorPopupPresented)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertEqual(1, fetchPresentationRequestUseCase.executeUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testValidatePresentationWithMultipleCredentialSuccess() async {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.executeUrlReturnValue = context

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(router.didCallStartPresentation)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isErrorPopupPresented)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertEqual(1, fetchPresentationRequestUseCase.executeUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testValidatePresentationFailure() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.executeUrlThrowableError = TestingError.error

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    XCTAssertFalse(viewModel.isTipPresented)
    XCTAssertFalse(viewModel.isSessionTimeoutPresented)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertEqual(1, fetchPresentationRequestUseCase.executeUrlCallsCount)

    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
    XCTAssertEqual(0, getCompatibleCredentialsUseCase.executeUsingCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testFetchCredentialFailed_networkError() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = CredentialOffer.Mock.sample

    fetchCredentialUseCase.executeFromThrowableError = NetworkError(status: .noConnection)

    await viewModel.setMetadataUrl(url)

    assertsNoInternetConnexion()
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testSubmitPresentationFailed_networkError() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    fetchPresentationRequestUseCase.executeUrlThrowableError = NetworkError(status: .noConnection)

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    if let error = viewModel.error as? InvitationError {
      XCTAssertEqual(error, .noConnection)
    } else {
      XCTFail("Expected InvitationError.noConnection")
    }
    XCTAssertFalse(router.didCallStartPresentation)
    XCTAssertFalse(viewModel.isSessionTimeoutPresented)
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertTrue(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testCheckInvitationTypeFailed_wrongScheme() async {
    checkInvitationTypeUseCase.executeUrlThrowableError = CheckInvitationTypeError.wrongScheme

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    if let error = viewModel.error as? InvitationError {
      XCTAssertEqual(error, .invalidQRCode)
    } else {
      XCTFail("Expected InvitationError.invalidQRCode")
    }
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  @MainActor
  func testClose() {
    viewModel.close()

    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testCloseErrorView() {
    viewModel.closeErrorView()

    XCTAssertFalse(viewModel.isErrorPopupPresented)
    XCTAssertNil(viewModel.error)
  }

  @MainActor
  func testCloseTipView() {
    viewModel.closeTipView()

    XCTAssertFalse(viewModel.isTipPresented)
  }

  @MainActor
  func testToggleTorch() {
    let initialState = viewModel.isTorchEnabled
    viewModel.toggleTorch()
    XCTAssertEqual(viewModel.isTorchEnabled, !initialState)
  }

  @MainActor
  func testOnAppearWithCredentials() async {
    getCredentialsCountUseCase.executeReturnValue = 2

    await viewModel.onAppear()

    XCTAssertFalse(viewModel.isTipPresented)
  }

  @MainActor
  func testOnAppearWithoutCredentials() async {
    getCredentialsCountUseCase.executeReturnValue = 0

    await viewModel.onAppear()

    XCTAssertTrue(viewModel.isTipPresented)
  }

  @MainActor
  func testOnAppearWithError() async {
    getCredentialsCountUseCase.executeThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertTrue(viewModel.isTipPresented)
  }

  @MainActor
  func testLogin_navigateToLogin() {
    viewModel.login()

    XCTAssertTrue(router.didCallLogin)
  }

  // MARK: Private

  // swiftlint: disable all
  private var validateCredentialOfferInvitationUrlUseCase = ValidateCredentialOfferInvitationUrlUseCaseProtocolSpy()
  private var fetchPresentationRequestUseCase = FetchPresentationRequestUseCaseProtocolSpy()
  private var checkInvitationTypeUseCase = CheckInvitationTypeUseCaseProtocolSpy()
  private var getCompatibleCredentialsUseCase = GetCompatibleCredentialsUseCaseProtocolSpy()
  private var fetchCredentialUseCase = FetchCredentialUseCaseProtocolSpy()
  private var getCredentialsCountUseCase = GetCredentialsCountUseCaseProtocolSpy()
  private var saveDeferredCredentialUseCase = SaveDeferredCredentialUseCaseProtocolSpy()
  private var mockRequestObject: RequestObject!
  private var router = InvitationRouterMock()

  private let mockDelegate = InvitationDelegateSpy()
  private var viewModel: CameraViewModel!
  private var mockCredentialWithKeyBinding: (AnyCredential, VaultKeyPair?)!
  private let url = URL(string: "openid-credential-offer://url")!
  private let scannerDelay: UInt64 = 0

  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!
  // swiftlint: enable all
}

extension CameraViewModelTests {

  private enum InvitationMode: Equatable {
    case deeplink(url: URL)
    case qr
  }

  @MainActor
  private func createViewModel(mode: InvitationMode = .qr) -> CameraViewModel {
    switch mode {
    case .qr: CameraViewModel(router: router, delegate: mockDelegate)
    case .deeplink(let url): CameraViewModel(url: url, router: router, delegate: mockDelegate)
    }
  }

  @MainActor
  private func assertsNoInternetConnexion() {
    XCTAssertTrue(viewModel.isErrorPopupPresented)
    if let error = viewModel.error as? InvitationError {
      XCTAssertEqual(error, .noConnection)
    } else {
      XCTFail("Expected InvitationError.noConnection")
    }
    XCTAssertFalse(router.didCallStartPresentation)
    XCTAssertFalse(viewModel.isSessionTimeoutPresented)
    XCTAssertFalse(router.didCallLogin)
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)
    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertFalse(fetchPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }
}
