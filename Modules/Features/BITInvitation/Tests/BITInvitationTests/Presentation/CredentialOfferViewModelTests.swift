// swiftlint: disable all
import Factory
import Foundation
import NavigatorUI
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

    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: mockTrustInformation)
  }

  func testInit_ValuesWithTrustStatement() {
    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: mockTrustInformation)

    XCTAssertEqual(viewModel.credential, mockCredential)
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertEqual(viewModel.trustInformation, mockTrustInformation)
    XCTAssertFalse(viewModel.isUnknownIssuerAlertShown)
    XCTAssertNil(viewModel.credentialViewModel)
  }

  func testInit_withoutTrustInformation() {
    viewModel = CredentialOfferViewModel(credential: mockCredential)

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
    viewModel = CredentialOfferViewModel(credential: mockCredential)

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertEqual(viewModel.trustInformation, mockTrustInformation)
    XCTAssertEqual(fetchIssuanceTrustInformationUseCase.callAsFunctionForCallsCount, 1)
    XCTAssertEqual(fetchIssuanceTrustInformationUseCase.callAsFunctionForReceivedCredential, mockCredential)
  }

  func testOnAppear_fetchTrustInformationFails_stateIsError() async {
    fetchIssuanceTrustInformationUseCase.callAsFunctionForThrowableError = TestingError.error

    viewModel = CredentialOfferViewModel(credential: mockCredential)

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
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertTrue(viewModel.isOfferAccepted)
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
    XCTAssertTrue(viewModel.isOfferDeclined)
  }

  func testConfirmDecline_deleteCredentialFails_stateIsError() async {
    deleteCredentialUseCase.executeThrowableError = TestingError.error

    await viewModel.confirmDecline()

    XCTAssertEqual(viewModel.state, .error)
  }

  func testAccept() async {
    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: mockTrustInformation)

    await viewModel.accept()

    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionReceivedCredential, mockCredential)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testAccept_unknownTrustIdentity_showsAlert() async {
    viewModel = CredentialOfferViewModel(credential: mockCredential, trustInformation: .Mock.unknownIdentity)

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
    if case .wrongData = viewModel.destination {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected destination: .wrongData")
    }
  }

  // MARK: Private

  private var viewModel: CredentialOfferViewModel!

  private var mockCredential = VerifiableCredential.Mock.sample
  private var mockTrustInformation = TrustInformation.Mock.trustedIdentity
  private let themeMock = "light"
  private var delayAfterAcceptingCredential: UInt64 = 0

  private var acceptCredentialUseCase: AcceptCredentialUseCaseProtocolSpy!
  private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocolSpy!
  private var fetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocolSpy!

  private func registerMocks() {
    deleteCredentialUseCase = DeleteCredentialUseCaseProtocolSpy()
    acceptCredentialUseCase = AcceptCredentialUseCaseProtocolSpy()
    acceptCredentialUseCase.callAsFunctionReturnValue = mockCredential
    fetchIssuanceTrustInformationUseCase = FetchIssuanceTrustInformationUseCaseProtocolSpy()
    fetchIssuanceTrustInformationUseCase.callAsFunctionForReturnValue = mockTrustInformation

    Container.shared.delayAfterAcceptingCredential.register { @MainActor in self.delayAfterAcceptingCredential }
    Container.shared.deleteCredentialUseCase.register { @MainActor in self.deleteCredentialUseCase }
    Container.shared.acceptCredentialUseCase.register { @MainActor in self.acceptCredentialUseCase }
    Container.shared.fetchIssuanceTrustInformationUseCase.register { @MainActor in self.fetchIssuanceTrustInformationUseCase }
    Container.shared.preferredUserLanguageCodes.register { ["de"] }
  }

}
