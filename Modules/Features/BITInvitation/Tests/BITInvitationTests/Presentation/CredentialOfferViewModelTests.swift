// swiftlint: disable all
import Factory
import Foundation
import NavigatorUI
import XCTest
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITInvitation
@testable import BITNonCompliance
@testable import BITTestingCore

@MainActor
final class CredentialOfferViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    viewModel = CredentialOfferViewModel(credential: mockCredential)
    viewModel.trustInformation = mockTrustInformation
    viewModel.actorCompliance = mockActorCompliance
  }

  func testInit_ValuesWithTrustStatement() {
    viewModel = CredentialOfferViewModel(credential: mockCredential)

    XCTAssertEqual(viewModel.credential, mockCredential)
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertNil(viewModel.trustInformation)
    XCTAssertEqual(viewModel.actorCompliance, .compliant)
    XCTAssertNil(viewModel.alert)
    XCTAssertNil(viewModel.credentialViewModel)
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
    XCTAssertEqual(viewModel.actorCompliance, mockActorCompliance)
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

    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.credential, mockCredential)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.trustInformation, mockTrustInformation)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.actorCompliance, mockActorCompliance)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceCallsCount, 1)
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertTrue(viewModel.isOfferAccepted)
  }

  func testConfirmAccept_acceptCredentialFails_stateIsError() async {
    acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceThrowableError = TestingError.error

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
    viewModel.actorCompliance = .compliant

    await viewModel.accept()

    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.credential, mockCredential)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.trustInformation, mockTrustInformation)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.actorCompliance, .compliant)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceCallsCount, 1)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testAccept_unknownTrustIdentity_showsAlert() async {
    viewModel = CredentialOfferViewModel(credential: mockCredential)
    viewModel.trustInformation = .Mock.unknownIdentity

    await viewModel.accept()

    XCTAssertEqual(viewModel.alert, .unknownIssuer)
    XCTAssertFalse(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceCalled)
  }

  func testAccept_nonCompliantActor_showsAlert() async {
    await viewModel.accept()

    XCTAssertEqual(viewModel.alert, .nonCompliantActor)
    XCTAssertFalse(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceCalled)
  }

  func testAccept_nonCompliantActorWithForce_accepts() async {
    await viewModel.accept(force: true)

    XCTAssertNil(viewModel.alert)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.credential, mockCredential)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.trustInformation, mockTrustInformation)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReceivedArguments?.actorCompliance, mockActorCompliance)
    XCTAssertEqual(acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceCallsCount, 1)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testDecline_success() {
    viewModel.decline()

    XCTAssertEqual(viewModel.state, .decline)
  }

  func testCancelDecline_success() {
    viewModel.cancelDecline()

    XCTAssertEqual(viewModel.state, .result)
  }

  // MARK: Private

  private var viewModel: CredentialOfferViewModel!

  private var mockCredential = VerifiableCredential.Mock.sample
  private var mockTrustInformation = TrustInformation.Mock.trustedIdentity
  private var mockActorCompliance = ActorCompliance.notCompliant(LocalizedDisplay(values: ["en": "reason EN"]))
  private let themeMock = "light"

  private var acceptCredentialUseCase: AcceptCredentialUseCaseProtocolSpy!
  private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocolSpy!
  private var fetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocolSpy!

  private func registerMocks() {
    deleteCredentialUseCase = DeleteCredentialUseCaseProtocolSpy()
    acceptCredentialUseCase = AcceptCredentialUseCaseProtocolSpy()
    acceptCredentialUseCase.callAsFunctionTrustInformationActorComplianceReturnValue = mockCredential
    fetchIssuanceTrustInformationUseCase = FetchIssuanceTrustInformationUseCaseProtocolSpy()
    fetchIssuanceTrustInformationUseCase.callAsFunctionForReturnValue = (mockTrustInformation, mockActorCompliance)

    Container.shared.deleteCredentialUseCase.register { @MainActor in self.deleteCredentialUseCase }
    Container.shared.acceptCredentialUseCase.register { @MainActor in self.acceptCredentialUseCase }
    Container.shared.fetchIssuanceTrustInformationUseCase.register { @MainActor in self.fetchIssuanceTrustInformationUseCase }
    Container.shared.preferredUserLanguageCodes.register { ["de"] }
  }

}
