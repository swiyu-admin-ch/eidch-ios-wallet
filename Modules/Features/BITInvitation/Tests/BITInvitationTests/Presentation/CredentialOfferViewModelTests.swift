// swiftlint: disable all
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITInvitation
@testable import BITTestingCore

@MainActor
final class CredentialOfferViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: mockTrustInformation, router: router, delegate: mockDelegate)
  }

  func testInit_ValuesWithTrustStatement() {
    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: mockTrustInformation, router: router, delegate: mockDelegate)

    XCTAssertEqual(viewModel.credential, mockCredential)
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.trustInformation, mockTrustInformation)
    XCTAssertFalse(viewModel.isUnknownIssuerAlertShown)
    XCTAssertNil(viewModel.credentialViewModel)
  }

  func testInit_withoutTrustInformation() {
    viewModel = CredentialOfferViewModel(credential: mockCredential, router: router, delegate: mockDelegate)

    XCTAssertEqual(viewModel.credential, mockCredential)
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertFalse(viewModel.isUnknownIssuerAlertShown)
    XCTAssertNil(viewModel.credentialViewModel)
    XCTAssertNil(viewModel.trustInformation)
  }

  func testOnAppear_withTrustInformation_stateIsResult() async {
    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertFalse(fetchIssuanceTrustInformationUseCase.callAsFunctionForCalled)
  }

  func testOnAppear_withoutTrustInformation_fetchTrust() async {
    viewModel = CredentialOfferViewModel(credential: mockCredential, router: router, delegate: mockDelegate)

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertEqual(viewModel.trustInformation, mockTrustInformation)
    XCTAssertEqual(fetchIssuanceTrustInformationUseCase.callAsFunctionForCallsCount, 1)
    XCTAssertEqual(fetchIssuanceTrustInformationUseCase.callAsFunctionForReceivedCredential, mockCredential)
  }

  func testOnAppear_fetchTrustInformationFails_stateIsError() async {
    fetchIssuanceTrustInformationUseCase.callAsFunctionForThrowableError = TestingError.error

    viewModel = CredentialOfferViewModel(credential: mockCredential, router: router, delegate: mockDelegate)

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .error)
    XCTAssertNil(viewModel.trustInformation)
  }

  func testUpdateCredentialViewModel_light_argumentsPassed() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(viewModel.credential.displays, mockCredential.displays)
  }

  func testConfirmAccept() async {
    await viewModel.confirmAccept()

    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionReceivedCredential, mockCredential)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionCallsCount, 1)
    XCTAssertTrue(mockDelegate.didSaveCredentialCalled)
    XCTAssertTrue(router.closeCalled)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testConfirmAccept_acceptCredentialFails_stateIsError() async {
    acceptCredentialUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.confirmAccept()

    XCTAssertEqual(viewModel.state, .error)
  }

  func testConfirmDecline() async {
    await viewModel.confirmDecline()

    XCTAssertEqual(deleteCredentialUseCase.executeReceivedCredential?.id, mockCredential.id)
    XCTAssertEqual(deleteCredentialUseCase.executeCallsCount, 1)
    XCTAssertTrue(mockDelegate.didDeclineCredentialCalled)
    XCTAssertTrue(router.closeCalled)
  }

  func testConfirmDecline_deleteCredentialFails_stateIsError() async {
    deleteCredentialUseCase.executeThrowableError = TestingError.error

    await viewModel.confirmDecline()

    XCTAssertEqual(viewModel.state, .error)
  }

  func testAccept() async {
    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: mockTrustInformation, router: router, delegate: mockDelegate)

    await viewModel.accept()

    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionReceivedCredential, mockCredential)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionCallsCount, 1)
    XCTAssertTrue(router.closeCalled)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testAccept_unknownTrustIdentity_showsAlert() async {
    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: .Mock.unknownIdentity, router: router, delegate: mockDelegate)

    await viewModel.accept()

    XCTAssertTrue(viewModel.isUnknownIssuerAlertShown)
  }

  func testDecline_success() {
    viewModel.decline()

    XCTAssertEqual(viewModel.state, .decline)
  }

  func testCancelDecline_success() {
    viewModel.cancelDecline()

    XCTAssertEqual(viewModel.state, .result)
  }

  func testOpenWrongData_success() {
    viewModel.openWrongData()
    XCTAssertTrue(router.wrongDataCalled)
  }

  // MARK: Private

  private var viewModel: CredentialOfferViewModel!

  private var mockCredential = VerifiableCredential.Mock.sample
  private var mockTrustInformation = TrustInformation.Mock.trustedIdentity
  private let themeMock = "light"
  private var router: MockCredentialOfferRouter!
  private var delayAfterAcceptingCredential: UInt64 = 0

  private var acceptCredentialUseCase: AcceptCredentialUseCaseProtocolSpy!
  private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocolSpy!
  private var fetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocolSpy!
  private let mockDelegate = InvitationDelegateSpy()

  private func registerMocks() {
    router = MockCredentialOfferRouter()

    deleteCredentialUseCase = DeleteCredentialUseCaseProtocolSpy()
    acceptCredentialUseCase = AcceptCredentialUseCaseProtocolSpy()
    acceptCredentialUseCase.callAsFunctionReturnValue = mockCredential
    fetchIssuanceTrustInformationUseCase = FetchIssuanceTrustInformationUseCaseProtocolSpy()
    fetchIssuanceTrustInformationUseCase.callAsFunctionForReturnValue = mockTrustInformation

    Container.shared.delayAfterAcceptingCredential.register { self.delayAfterAcceptingCredential }
    Container.shared.deleteCredentialUseCase.register { self.deleteCredentialUseCase }
    Container.shared.acceptCredentialUseCase.register { self.acceptCredentialUseCase }
    Container.shared.fetchIssuanceTrustInformationUseCase.register { self.fetchIssuanceTrustInformationUseCase }
    Container.shared.preferredUserLanguageCodes.register { ["de"] }
  }

}
