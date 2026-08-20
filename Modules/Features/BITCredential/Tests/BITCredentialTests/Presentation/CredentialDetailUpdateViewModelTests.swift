import Factory
import FactoryTesting
import Testing
@testable import BITAnalytics
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// MARK: - CredentialDetailUpdateViewModelTests

@Suite(.container) @MainActor
struct CredentialDetailUpdateViewModelTests {

  // MARK: Lifecycle

  init() {
    var credential = VerifiableCredential.Mock.sample
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: "refresh-token",
      dpopBinding: credential.authentication.dpopBinding)

    let analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    let refreshCredentialUseCaseSpy = RefreshVerifiableCredentialUseCaseProtocolSpy()
    refreshCredentialUseCaseSpy.callAsFunctionReturnValue = refreshedCredential

    Container.shared.analytics.register { @MainActor in analytics }
    Container.shared.refreshCredentialUseCase.register { @MainActor in refreshCredentialUseCaseSpy }

    self.credential = credential
    self.analyticsProvider = analyticsProvider
    self.refreshCredentialUseCaseSpy = refreshCredentialUseCaseSpy
    viewModel = CredentialDetailUpdateViewModel(credential: credential)
  }

  // MARK: Internal

  @Test
  func primaryAction_refreshModeSuccess_callsOnSuccess() async {
    var successCredential: VerifiableCredential?

    await viewModel.primaryAction { credential in
      successCredential = credential
    }

    #expect(successCredential == refreshedCredential)
    #expect(refreshCredentialUseCaseSpy.callAsFunctionCallsCount == 1)
    #expect(refreshCredentialUseCaseSpy.callAsFunctionReceivedCredential == credential)
    #expect(!viewModel.isLoading)
    #expect(!viewModel.isErrorPresented)
  }

  @Test
  func init_refreshMode_setsIssuerDisplayFromCredential() {
    #expect(viewModel.issuerDisplay == credential.issuerDisplays.findDisplayWithFallback())
  }

  @Test
  func primaryAction_refreshModeFailure_showsError() async {
    var successCredential: VerifiableCredential?
    refreshCredentialUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.primaryAction { credential in
      successCredential = credential
    }

    #expect(successCredential == nil)
    #expect(viewModel.isErrorPresented)
    #expect(!viewModel.isLoading)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func primaryAction_withoutRefreshToken_returnsNil() async {
    var successCredential: VerifiableCredential?
    var credentialWithoutRefreshToken = credential
    credentialWithoutRefreshToken.authentication = CredentialAuthentication(
      accessToken: credentialWithoutRefreshToken.authentication.accessToken,
      tokenType: credentialWithoutRefreshToken.authentication.tokenType,
      refreshToken: nil,
      dpopBinding: credentialWithoutRefreshToken.authentication.dpopBinding)
    let viewModel = CredentialDetailUpdateViewModel(credential: credentialWithoutRefreshToken)

    await viewModel.primaryAction { credential in
      successCredential = credential
    }

    #expect(successCredential == nil)
    #expect(refreshCredentialUseCaseSpy.callAsFunctionCallsCount == 0)
    #expect(!viewModel.isLoading)
    #expect(!viewModel.isErrorPresented)
  }

  @Test
  func primaryAction_withDeferredCredential_doesNothing() async {
    var successCredential: VerifiableCredential?
    let viewModel = CredentialDetailUpdateViewModel(credential: DeferredCredential.Mock.sample)

    await viewModel.primaryAction { credential in
      successCredential = credential
    }

    #expect(successCredential == nil)
    #expect(refreshCredentialUseCaseSpy.callAsFunctionCallsCount == 0)
    #expect(!viewModel.isLoading)
    #expect(!viewModel.isErrorPresented)
  }

  @Test
  func hideError_resetsPresentationState() {
    viewModel.isErrorPresented = true

    viewModel.hideError()

    #expect(!viewModel.isErrorPresented)
  }

  @Test
  func primaryAction_infoMode_doesNothing() async {
    var successCredential: VerifiableCredential?
    let viewModel = CredentialDetailUpdateViewModel(issuerDisplay: nil)

    await viewModel.primaryAction { credential in
      successCredential = credential
    }

    #expect(successCredential == nil)
    #expect(refreshCredentialUseCaseSpy.callAsFunctionCallsCount == 0)
    #expect(!viewModel.isLoading)
    #expect(!viewModel.isErrorPresented)
  }

  // MARK: Private

  private let credential: VerifiableCredential
  private let refreshedCredential = VerifiableCredential.Mock.diploma

  private let analyticsProvider: MockProvider
  private let refreshCredentialUseCaseSpy: RefreshVerifiableCredentialUseCaseProtocolSpy
  private let viewModel: CredentialDetailUpdateViewModel
}
