import Factory
import XCTest
@testable import BITAnalytics
@testable import BITAnalyticsMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

// MARK: - CredentialDetailUpdateViewModelTests

@MainActor
final class CredentialDetailUpdateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    credential = VerifiableCredential.Mock.sample
    credential!.authentication = CredentialAuthentication(
      accessToken: credential!.authentication.accessToken,
      tokenType: credential!.authentication.tokenType,
      refreshToken: "refresh-token",
      dpopBinding: credential!.authentication.dpopBinding)

    analyticsProvider = MockProvider()
    analytics = Analytics()
    analytics.register(analyticsProvider)

    refreshCredentialUseCaseSpy = RefreshVerifiableCredentialUseCaseProtocolSpy()
    refreshCredentialUseCaseSpy.callAsFunctionReturnValue = refreshedCredential

    Container.shared.analytics.register { @MainActor in self.analytics }
    Container.shared.refreshCredentialUseCase.register { @MainActor in self.refreshCredentialUseCaseSpy }

    viewModel = CredentialDetailUpdateViewModel(credential: credential!)
    successCredential = nil
  }

  func testPrimaryAction_refreshModeSuccess_callsOnSuccess() async {
    await viewModel.primaryAction { credential in
      self.successCredential = credential
    }

    XCTAssertEqual(successCredential, refreshedCredential)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 1)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionReceivedCredential, credential)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertFalse(viewModel.isErrorPresented)
  }

  func testInit_refreshMode_setsIssuerDisplayFromCredential() {
    XCTAssertEqual(viewModel.issuerDisplay, credential?.issuerDisplays.findDisplayWithFallback())
  }

  func testPrimaryAction_refreshModeFailure_showsError() async {
    refreshCredentialUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.primaryAction { credential in
      self.successCredential = credential
    }

    XCTAssertNil(successCredential)
    XCTAssertTrue(viewModel.isErrorPresented)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertEqual(analyticsProvider.logCounter, 1)
  }

  func testPrimaryAction_withoutRefreshToken_returnsNil() async throws {
    var credentialWithoutRefreshToken = try XCTUnwrap(credential)
    credentialWithoutRefreshToken.authentication = CredentialAuthentication(
      accessToken: credentialWithoutRefreshToken.authentication.accessToken,
      tokenType: credentialWithoutRefreshToken.authentication.tokenType,
      refreshToken: nil,
      dpopBinding: credentialWithoutRefreshToken.authentication.dpopBinding)
    viewModel = CredentialDetailUpdateViewModel(credential: credentialWithoutRefreshToken)

    await viewModel.primaryAction { credential in
      self.successCredential = credential
    }

    XCTAssertNil(successCredential)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 0)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertFalse(viewModel.isErrorPresented)
  }

  func testPrimaryAction_withDeferredCredential_doesNothing() async {
    viewModel = CredentialDetailUpdateViewModel(credential: DeferredCredential.Mock.sample)

    await viewModel.primaryAction { credential in
      self.successCredential = credential
    }

    XCTAssertNil(successCredential)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 0)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertFalse(viewModel.isErrorPresented)
  }

  func testHideError_resetsPresentationState() {
    viewModel.isErrorPresented = true

    viewModel.hideError()

    XCTAssertFalse(viewModel.isErrorPresented)
  }

  func testPrimaryAction_infoMode_doesNothing() async {
    viewModel = CredentialDetailUpdateViewModel(issuerDisplay: nil)

    await viewModel.primaryAction { credential in
      self.successCredential = credential
    }

    XCTAssertNil(successCredential)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 0)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertFalse(viewModel.isErrorPresented)
  }

  // MARK: Private

  private var credential: VerifiableCredential!
  private let refreshedCredential = VerifiableCredential.Mock.diploma

  private var analytics: Analytics!
  private var analyticsProvider: MockProvider!
  private var refreshCredentialUseCaseSpy: RefreshVerifiableCredentialUseCaseProtocolSpy!
  private var successCredential: VerifiableCredential?
  private var viewModel: CredentialDetailUpdateViewModel!
}
