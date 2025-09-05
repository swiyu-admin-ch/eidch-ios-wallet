import Factory
import Foundation
import Spyable
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITInvitation
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - CredentialOfferViewModelTests

@MainActor
final class CredentialOfferViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    router = MockCredentialOfferRouter()
    createSuccessState()

    viewModel = CredentialOfferViewModel(credential: credentialMock, trustStatement: trustStatementMock, router: router)
  }

  func testInit_ValuesWithTrustStatement() async {
    viewModel = CredentialOfferViewModel(credential: credentialMock, trustStatement: trustStatementMock, router: router)

    XCTAssertEqual(viewModel.credential, credentialMock)
    XCTAssertEqual(viewModel.state, .result)
    XCTAssertEqual(viewModel.issuerTrustStatus, .verified)
  }

  func testInit_ValuesWithoutTrustStatement() async {
    viewModel = CredentialOfferViewModel(credential: credentialMock, trustStatement: nil, router: router)

    XCTAssertEqual(viewModel.credential, credentialMock)
    XCTAssertEqual(viewModel.state, .result)
    XCTAssertEqual(viewModel.issuerTrustStatus, .unverified)
  }

  func testUpdateCredentialViewModel_light_setsViewModel() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, .Mock.lightEnglish)
    XCTAssertEqual(viewModel.credentialViewModel?.credential, credentialMock)
  }

  func testUpdateCredentialViewModel_light_argumentsPassed() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, credentialMock.displays)
  }

  func testAccept_loadingStateThencloseCalled() async {
    await viewModel.send(event: .accept)
    XCTAssertEqual(viewModel.state, .loading)

    try? await Task.sleep(nanoseconds: delayAfterAcceptingCredential + 100_000_000)

    XCTAssertTrue(router.closeCalled)
  }

  func testDecline_setsDeclineState() async {
    await viewModel.send(event: .decline)

    XCTAssertEqual(viewModel.state, .decline)
  }

  func testDeclineConfirmation_correctCalls() async {
    await viewModel.send(event: .confirmDecline)

    XCTAssertTrue(deleteCredentialUseCaseSpy.executeCalled)
    XCTAssertEqual(deleteCredentialUseCaseSpy.executeCallsCount, 1)
    XCTAssertTrue(router.closeCalled)
  }

  func testSend_declineConfirmation_setsErrorState() async {
    deleteCredentialUseCaseSpy.executeThrowableError = TestingError.error

    await viewModel.send(event: .confirmDecline)

    XCTAssertTrue(deleteCredentialUseCaseSpy.executeCalled)
    XCTAssertEqual(deleteCredentialUseCaseSpy.executeCallsCount, 1)
    XCTAssertFalse(router.closeCalled)
    XCTAssertEqual(viewModel.state, .error)
    XCTAssertNotNil(viewModel.stateError)
  }

  func testSend_declineCancellation_setsResultState() async {
    await viewModel.send(event: .cancelDecline)
    XCTAssertEqual(viewModel.state, .result)
  }

  func testSend_openWrongData_correctCalls() async {
    await viewModel.send(event: .openWrongData)
    XCTAssertTrue(router.wrongDataCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: CredentialOfferViewModel!
  private var credentialMock = Credential.Mock.sample
  private var trustStatementMock: TrustStatement? = TrustStatementPayload.Mock.validSample
  private let themeMock = "light"
  private var router: MockCredentialOfferRouter!
  private var delayAfterAcceptingCredential: UInt64 = 0
  private var deleteCredentialUseCaseSpy = DeleteCredentialUseCaseProtocolSpy()
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()
  // swiftlint:enable all

  private let issuerDisplaysMock = CredentialIssuerDisplay(id: UUID(), credentialId: nil, image: nil)

  private func registerMocks() {
    Container.shared.delayAfterAcceptingCredential.register { self.delayAfterAcceptingCredential }
    Container.shared.deleteCredentialUseCase.register { self.deleteCredentialUseCaseSpy }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCaseSpy }
    Container.shared.preferredUserLanguageCodes.register { ["de"] }
  }

  private func createSuccessState() {
    getCredentialDisplayUseCaseSpy.executeForColorSchemeReturnValue = .Mock.lightEnglish
  }

}
