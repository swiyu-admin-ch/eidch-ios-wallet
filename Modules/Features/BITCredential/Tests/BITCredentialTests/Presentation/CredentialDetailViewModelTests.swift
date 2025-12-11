import Factory
import XCTest
@testable import BITActivity
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

    viewModel = CredentialDetailViewModel(credentialMock)

    createSuccessState()
  }

  func test_init() {
    viewModel = CredentialDetailViewModel(credentialMock)

    XCTAssertFalse(viewModel.isDeleteCredentialAlertPresented)
    XCTAssertEqual(viewModel.credential, credentialMock)
  }

  func test_onAppear_updatesCredentialAndViewModel() async {
    await viewModel.onAppear()

    XCTAssertEqual(viewModel.credential, updateCredentialMock)
    XCTAssertEqual(viewModel.credentialViewModel?.credential, updateCredentialMock)
    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, credentialDisplayMock)
    XCTAssertEqual(viewModel.activities.map(\.activity), activitiesMock)
  }

  func test_onAppear_argumentsPassed() async {
    await viewModel.onAppear()

    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReceivedArguments?.credentialId, credentialMock.id)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReceivedArguments?.limit, 2)
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

  func test_delete_success() async {
    await viewModel.deleteCredential()

    XCTAssertTrue(deleteCredentialUseCaseSpy.executeCalled)
  }

  func test_delete_failure() async {
    deleteCredentialUseCaseSpy.executeThrowableError = TestingError.error

    await viewModel.deleteCredential()

    XCTAssertTrue(deleteCredentialUseCaseSpy.executeCalled)
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
  private let credentialMock = VerifiableCredential.Mock.sample
  private let updateCredentialMock = VerifiableCredential.Mock.diploma
  private let credentialDisplayMock = CredentialDisplay.Mock.lightEnglish
  private let activitiesMock: [Activity] = [.Mock.issueTrusted, .Mock.presentationAcceptedTrusted]
  private let themeMock = "light"
  private var viewModel: CredentialDetailViewModel!

  private var deleteCredentialUseCaseSpy = DeleteCredentialUseCaseProtocolSpy()
  private var checkAndUpdateCredentialStatusUseCaseSpy = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()
  private var getCredentialActivitiesUseCaseSpy = GetCredentialActivitiesUseCaseProtocolSpy()

  // swiftlint:enable all

  private func createSuccessState() {
    checkAndUpdateCredentialStatusUseCaseSpy.executeForReturnValue = updateCredentialMock
    deleteCredentialUseCaseSpy.executeClosure = { _ in }
    getCredentialDisplayUseCaseSpy.executeForColorSchemeReturnValue = credentialDisplayMock
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = activitiesMock
  }

  private func registerMocks() {
    Container.shared.deleteCredentialUseCase.register { self.deleteCredentialUseCaseSpy }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCaseSpy }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCaseSpy }
    Container.shared.getCredentialActivitiesUseCase.register { self.getCredentialActivitiesUseCaseSpy }
  }

}
