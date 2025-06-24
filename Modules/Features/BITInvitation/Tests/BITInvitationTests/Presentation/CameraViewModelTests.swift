import BITCrypto
import BITNetworking
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAnalytics
@testable import BITAnalyticsMocks
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITInvitation
@testable import BITOpenID
@testable import BITPresentation
@testable import BITSdJWTMocks
@testable import BITTestingCore

// MARK: - CameraViewModelTests

final class CameraViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    Container.shared.validateCredentialOfferInvitationUrlUseCase.register { self.validateCredentialOfferInvitationUrlUseCase }
    Container.shared.processPresentationRequestUseCase.register { self.processPresentationRequestUseCase }
    Container.shared.checkInvitationTypeUseCase.register { self.checkInvitationTypeUseCase }
    Container.shared.getCompatibleCredentialsUseCase.register { self.getCompatibleCredentialsUseCase }
    Container.shared.fetchCredentialUseCase.register { self.fetchCredentialUseCase }
    Container.shared.getCredentialsCountUseCase.register { self.getCredentialsCountUseCase }

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
  func testWithInitialData() async {
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
    let credential = Credential.Mock.sample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = (credential, TrustStatementPayload.Mock.validSample)

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(router.didCallCredentialOffer)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isErrorPopupPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)

    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOfferSuccess_withRouter() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    let credential = Credential.Mock.sample

    let viewModel = CameraViewModel(router: router)

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer

    fetchCredentialUseCase.executeFromReturnValue = (credential, TrustStatementPayload.Mock.validSample)

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

    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOfferSuccess_deeplink() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    let credential = Credential.Mock.sample

    getCredentialsCountUseCase.executeReturnValue = 2
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = (credential, TrustStatementPayload.Mock.validSample)

    viewModel = createViewModel(mode: .deeplink(url: url))
    await viewModel.onAppear()

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)
    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(1, fetchCredentialUseCase.executeFromCallsCount)
    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
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
    XCTAssertEqual(viewModel.error, .invalidQRCode)
    XCTAssertTrue(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
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
    XCTAssertEqual(viewModel.error, .validationFailed)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(fetchCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  @MainActor
  func testValidateCredentialOfferUnknownIssuer() async {
    let mockCredentialOffer = CredentialOffer.Mock.sample
    guard let mockOfferIssuerUrl = URL(string: mockCredentialOffer.issuer) else {
      XCTFail("unexpected URL format of the credential offer issuer URL")
      return
    }

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.credentialOffer
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromThrowableError = FetchAnyVerifiableCredentialError.unknownIssuer

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    XCTAssertEqual(viewModel.error, .unknownIssuer)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)
    XCTAssertEqual(url, checkInvitationTypeUseCase.executeUrlReceivedUrl)

    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
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
    XCTAssertEqual(viewModel.error, .expiredInvitation)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)

    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertEqual(1, validateCredentialOfferInvitationUrlUseCase.executeCallsCount)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(fetchCredentialUseCase.executeFromCalled)
    XCTAssertEqual(fetchCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }

  // MARK: - Presentation

  @MainActor
  func testValidatePresentationWithOneCredentialSuccess() async throws {
    let bundle = PresentationRequestContext.Mock.vcSdJwtSample

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    processPresentationRequestUseCase.executeUrlReturnValue = bundle

    await viewModel.setMetadataUrl(url)

    XCTAssertFalse(router.didCallPresentationReview)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isErrorPopupPresented)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertEqual(1, processPresentationRequestUseCase.executeUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testValidatePresentationWithMultipleCredentialSuccess() async throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample
    context.inputDescriptorId = "test-id"

    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    processPresentationRequestUseCase.executeUrlReturnValue = context

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(router.didCallCompatibleCredentials)
    XCTAssertFalse(router.didCallPresentationReview)
    XCTAssertFalse(viewModel.isTorchEnabled)
    XCTAssertFalse(viewModel.isErrorPopupPresented)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertEqual(1, processPresentationRequestUseCase.executeUrlCallsCount)

    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testValidatePresentationFailure() async {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    processPresentationRequestUseCase.executeUrlThrowableError = TestingError.error

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    XCTAssertFalse(viewModel.isTipPresented)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertEqual(1, checkInvitationTypeUseCase.executeUrlCallsCount)

    XCTAssertTrue(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertEqual(1, processPresentationRequestUseCase.executeUrlCallsCount)

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
  func testSubmitPresentationFailed_networkError() async throws {
    checkInvitationTypeUseCase.executeUrlReturnValue = InvitationType.presentation
    processPresentationRequestUseCase.executeUrlThrowableError = NetworkError(status: .noConnection)

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    XCTAssertEqual(viewModel.error, .noConnection)
    XCTAssertFalse(router.didCallCompatibleCredentials)
    XCTAssertFalse(router.didCallPresentationReview)
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertTrue(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
    XCTAssertFalse(fetchCredentialUseCase.executeFromCalled)
  }

  @MainActor
  func testCheckInvitationTypeFailed_wrongScheme() async throws {
    checkInvitationTypeUseCase.executeUrlThrowableError = CheckCameraError.wrongScheme

    await viewModel.setMetadataUrl(url)

    XCTAssertTrue(viewModel.isErrorPopupPresented)
    XCTAssertEqual(viewModel.error, .invalidQRCode)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  @MainActor
  func testClose() async {
    viewModel.close()

    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testCloseErrorView() async {
    viewModel.closeErrorView()

    XCTAssertFalse(viewModel.isErrorPopupPresented)
    XCTAssertNil(viewModel.error)
  }

  @MainActor
  func testCloseTipView() async {
    viewModel.closeTipView()

    XCTAssertFalse(viewModel.isTipPresented)
  }

  @MainActor
  func testToggleTorch() async {
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

  // MARK: Private

  // swiftlint: disable all
  private var validateCredentialOfferInvitationUrlUseCase = ValidateCredentialOfferInvitationUrlUseCaseProtocolSpy()
  private var processPresentationRequestUseCase = ProcessPresentationRequestUseCaseProtocolSpy()
  private var checkInvitationTypeUseCase = CheckInvitationTypeUseCaseProtocolSpy()
  private var getCompatibleCredentialsUseCase = GetCompatibleCredentialsUseCaseProtocolSpy()
  private var fetchCredentialUseCase = FetchCredentialUseCaseProtocolSpy()
  private var getCredentialsCountUseCase = GetCredentialsCountUseCaseProtocolSpy()
  private var mockRequestObject: RequestObject!
  private var router = InvitationRouterMock()

  private var viewModel: CameraViewModel!
  private var mockCredentialWithKeyBinding: (AnyCredential, KeyPair?)!
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
    case .qr: CameraViewModel(router: router)
    case .deeplink(let url): CameraViewModel(url: url, router: router)
    }
  }

  @MainActor
  private func assertsNoInternetConnexion() {
    XCTAssertTrue(viewModel.isErrorPopupPresented)
    XCTAssertEqual(viewModel.error, .noConnection)
    XCTAssertFalse(router.didCallCompatibleCredentials)
    XCTAssertFalse(router.didCallPresentationReview)
    XCTAssertFalse(viewModel.isTorchEnabled)

    XCTAssertEqual(url, validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl)
    XCTAssertTrue(validateCredentialOfferInvitationUrlUseCase.executeCalled)
    XCTAssertTrue(checkInvitationTypeUseCase.executeUrlCalled)
    XCTAssertFalse(processPresentationRequestUseCase.executeUrlCalled)
    XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
  }
}
