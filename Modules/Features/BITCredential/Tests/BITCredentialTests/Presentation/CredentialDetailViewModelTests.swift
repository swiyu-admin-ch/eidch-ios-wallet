import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

@MainActor
final class CredentialDetailViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    viewModel = CredentialDetailViewModel(credentialMock, router: mockRouter)

    createSuccessState()
  }

  func test_init() {
    viewModel = CredentialDetailViewModel(credentialMock, router: mockRouter)

    XCTAssertFalse(viewModel.isDeleteCredentialAlertPresented)
    XCTAssertEqual(viewModel.credential, credentialMock)
  }

  func test_onAppear_updatesCredentialAndViewModel() async {
    await viewModel.onAppear()

    XCTAssertEqual(viewModel.credential, updateCredentialMock)
    XCTAssertEqual(viewModel.credentialViewModel?.credential, updateCredentialMock)
    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, credentialDisplayMock)
  }

  func test_onAppear_argumentsPassed() async {
    await viewModel.onAppear()

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCaseSpy.executeForReceivedCredential, credentialMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, "")
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, updateCredentialMock.displays)
  }

  func test_onRefresh() async {
    await viewModel.refresh()

    XCTAssertEqual(viewModel.credential, updateCredentialMock)
    XCTAssertEqual(viewModel.credentialViewModel?.credential, updateCredentialMock)
    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, credentialDisplayMock)
  }

  func test_onRefresh_argumentsPassed() async {
    await viewModel.refresh()

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCaseSpy.executeForReceivedCredential, credentialMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, "")
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, updateCredentialMock.displays)
  }

  func test_openWrongData() {
    viewModel.openWrongdata()

    XCTAssertTrue(mockRouter.didCallWrongData)
  }

  func test_close() {
    viewModel.close()

    XCTAssertTrue(mockRouter.closeCalled)
  }

  func test_delete_success() async {
    await viewModel.deleteCredential()

    XCTAssertTrue(deleteCredentialUseCaseSpy.executeCalled)
    XCTAssertTrue(mockRouter.closeCalled)
  }

  func test_delete_failure() async {
    deleteCredentialUseCaseSpy.executeThrowableError = TestingError.error

    await viewModel.deleteCredential()

    XCTAssertTrue(deleteCredentialUseCaseSpy.executeCalled)
    XCTAssertFalse(mockRouter.closeCalled)
  }

  func testUpdateCredentialViewModel_light_setsViewModel() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, .Mock.lightEnglish)
    XCTAssertEqual(viewModel.credentialViewModel?.credential, credentialMock)
  }

  func testUpdateCredentialViewModel_argumentsPassed() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, credentialMock.displays)
  }

  @MainActor
  func testWillResignActive() async {
    viewModel.isDeleteCredentialAlertPresented = true

    NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil, userInfo: nil)

    try? await Task.sleep(nanoseconds: 200_000_000)
    XCTAssertFalse(viewModel.isDeleteCredentialAlertPresented)
  }

  // MARK: Private

  // swiftlint:disable all
  private let credentialMock = Credential.Mock.sample
  private let updateCredentialMock = Credential.Mock.diploma
  private let credentialDisplayMock = CredentialDisplay.Mock.lightEnglish
  private let themeMock = "light"
  private var mockRouter = CredentialDetailRouterMock()
  private var viewModel: CredentialDetailViewModel!

  private var deleteCredentialUseCaseSpy = DeleteCredentialUseCaseProtocolSpy()
  private var checkAndUpdateCredentialStatusUseCaseSpy = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()

  // swiftlint:enable all

  private func createSuccessState() {
    checkAndUpdateCredentialStatusUseCaseSpy.executeForReturnValue = updateCredentialMock
    deleteCredentialUseCaseSpy.executeClosure = { _ in }
    getCredentialDisplayUseCaseSpy.executeForColorSchemeReturnValue = credentialDisplayMock
  }

  private func registerMocks() {
    Container.shared.deleteCredentialUseCase.register { self.deleteCredentialUseCaseSpy }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCaseSpy }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCaseSpy }
  }

}
