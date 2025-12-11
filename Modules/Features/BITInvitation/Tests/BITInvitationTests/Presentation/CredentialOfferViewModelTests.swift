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

    viewModel = CredentialOfferViewModel(credential: credentialMock, trustInformation: trustInformationMock, router: router)
  }

  func testInit_ValuesWithTrustStatement() async {
    viewModel = CredentialOfferViewModel(credential: credentialMock, trustInformation: trustInformationMock, router: router)

    XCTAssertEqual(viewModel.credential, credentialMock)
    XCTAssertEqual(viewModel.state, .result)
    XCTAssertEqual(viewModel.trustInformation, trustInformationMock)
  }

  func testUpdateCredentialViewModel_light_argumentsPassed() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(viewModel.credential.displays, credentialMock.displays)
  }

  func testAccept_loadingStateThencloseCalled() async {
    await viewModel.send(event: .accept)

    XCTAssertEqual(viewModel.state, .loading)
    try? await Task.sleep(nanoseconds: delayAfterAcceptingCredential + 100_000_000)
    XCTAssertFalse(viewModel.isUnknownIssuerAlertShown)
    XCTAssertTrue(router.closeCalled)
  }

  func testAccept_unknownTrustIdentity_showsAlert() async {
    viewModel = CredentialOfferViewModel(credential: credentialMock, trustInformation: .Mock.unknownIdentity, router: router)

    await viewModel.send(event: .accept)
    XCTAssertEqual(viewModel.state, .result)
    XCTAssertTrue(viewModel.isUnknownIssuerAlertShown)
    XCTAssertFalse(router.closeCalled)
  }

  func testConfirmAccept_unknownTrustIdentity_loadingStateThenCloseCalled() async {
    viewModel = CredentialOfferViewModel(credential: credentialMock, trustInformation: .Mock.unknownIdentity, router: router)

    await viewModel.send(event: .confirmAccept)

    XCTAssertEqual(viewModel.state, .loading)
    try? await Task.sleep(nanoseconds: delayAfterAcceptingCredential + 100_000_000)
    XCTAssertFalse(viewModel.isUnknownIssuerAlertShown)
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
  private var credentialMock = VerifiableCredential.Mock.sample
  private var trustInformationMock = TrustInformation.Mock.trustedIdentity
  private let themeMock = "light"
  private var router: MockCredentialOfferRouter!
  private var delayAfterAcceptingCredential: UInt64 = 0
  private var deleteCredentialUseCaseSpy = DeleteCredentialUseCaseProtocolSpy()
  // swiftlint:enable all

  private let issuerDisplaysMock = CredentialIssuerDisplay(id: UUID(), credentialId: nil, image: nil)

  private func registerMocks() {
    Container.shared.delayAfterAcceptingCredential.register { self.delayAfterAcceptingCredential }
    Container.shared.deleteCredentialUseCase.register { self.deleteCredentialUseCaseSpy }
    Container.shared.preferredUserLanguageCodes.register { ["de"] }
  }

}
