import BITCore
import Factory
import Foundation
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// MARK: - IssuanceTypeViewModelTests

// swiftlint:disable implicitly_unwrapped_optional

@MainActor
final class IssuanceTypeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.preferredUserLocales.register { ["en-CH"] }

    getCredentialIssuanceSummaryUseCaseSpy = GetCredentialIssuanceSummaryUseCaseProtocolSpy()
    Container.shared.getCredentialIssuanceSummaryUseCase.register { @MainActor in self.getCredentialIssuanceSummaryUseCaseSpy }
    let getCredentialRefreshThresholdUseCaseSpy = GetCredentialRefreshThresholdUseCaseProtocolSpy()
    getCredentialRefreshThresholdUseCaseSpy.callAsFunctionForReturnValue = 1
    Container.shared.getCredentialRefreshThresholdUseCase.register { getCredentialRefreshThresholdUseCaseSpy }
    self.getCredentialRefreshThresholdUseCaseSpy = getCredentialRefreshThresholdUseCaseSpy

    getCredentialUseCaseSpy = GetCredentialUseCaseProtocolSpy()
    Container.shared.getCredentialUseCase.register { @MainActor in self.getCredentialUseCaseSpy }
    refreshCredentialUseCaseSpy = RefreshVerifiableCredentialUseCaseProtocolSpy()
    Container.shared.refreshCredentialUseCase.register { @MainActor in self.refreshCredentialUseCaseSpy }

    viewModel = IssuanceTypeViewModel(credentialId: VerifiableCredential.Mock.sample.id)
  }

  func testOnAppear_refreshesCredentialFromDatabase() async {
    getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForReturnValue = CredentialIssuanceSummary(issuedAt: issuedAtMock, available: 1, total: 1)

    await viewModel.onAppear()

    guard case .result(.single, let timeStamp) = viewModel.state else {
      return XCTFail("Expected result state")
    }

    XCTAssertEqual(timeStamp, "04.02.2026 | 15:07")
    XCTAssertEqual(getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForReceivedCredentialId, VerifiableCredential.Mock.sample.id)
  }

  func testOnAppear_updatesAvailableBatchCount() async {
    getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForReturnValue = CredentialIssuanceSummary(
      issuedAt: issuedAtMock,
      available: 0,
      total: 2)

    await viewModel.onAppear()

    guard case .result(.batch(let batchViewModel), _) = viewModel.state else {
      return XCTFail("Expected batch issuance type")
    }

    XCTAssertEqual(batchViewModel.available, 0)
  }

  func testOnAppear_withBatchCredentialUsesRefreshThresholdUseCase() async {
    getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForReturnValue = CredentialIssuanceSummary(
      issuedAt: issuedAtMock,
      available: 7,
      total: 10)
    getCredentialRefreshThresholdUseCaseSpy.callAsFunctionForReturnValue = 4

    await viewModel.onAppear()

    guard case .result(.batch(let batchViewModel), _) = viewModel.state else {
      return XCTFail("Expected batch issuance type")
    }

    XCTAssertEqual(batchViewModel.available, 7)
    XCTAssertEqual(batchViewModel.refreshThreshold, 4)
    XCTAssertEqual(getCredentialRefreshThresholdUseCaseSpy.callAsFunctionForReceivedBatchSize, 10)
  }

  func testRefreshBatchCredential_success_refreshesCredentialAndSummary() async {
    let credential = VerifiableCredential.Mock.sample
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = credential
    refreshCredentialUseCaseSpy.callAsFunctionReturnValue = credential
    getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForReturnValue = CredentialIssuanceSummary(
      issuedAt: issuedAtMock,
      available: 5,
      total: 10)

    await viewModel.refreshBatchCredential()

    XCTAssertEqual(viewModel.notificationState, .success)
    XCTAssertFalse(viewModel.isRefreshing)
    XCTAssertEqual(getCredentialUseCaseSpy.callAsFunctionIdReceivedId, credential.id)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 1)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionReceivedCredential, credential)

    guard case .result(.batch(let batchViewModel), _) = viewModel.state else {
      return XCTFail("Expected batch issuance type")
    }

    XCTAssertEqual(batchViewModel.available, 5)
  }

  func testRefreshBatchCredential_withNonVerifiableCredential_setsFailureNotification() async {
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = DeferredCredential.Mock.sample

    await viewModel.refreshBatchCredential()

    XCTAssertEqual(viewModel.notificationState, .failure)
    XCTAssertFalse(viewModel.isRefreshing)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 0)
    XCTAssertEqual(getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForCallsCount, 0)
  }

  func testRefreshBatchCredential_getCredentialFails_setsFailureNotification() async {
    getCredentialUseCaseSpy.callAsFunctionIdThrowableError = TestingError.error

    await viewModel.refreshBatchCredential()

    XCTAssertEqual(viewModel.notificationState, .failure)
    XCTAssertFalse(viewModel.isRefreshing)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 0)
  }

  func testRefreshBatchCredential_refreshFails_setsFailureNotification() async {
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = VerifiableCredential.Mock.sample
    refreshCredentialUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.refreshBatchCredential()

    XCTAssertEqual(viewModel.notificationState, .failure)
    XCTAssertFalse(viewModel.isRefreshing)
    XCTAssertEqual(getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForCallsCount, 0)
  }

  func testRefreshBatchCredential_summaryFails_setsFailureNotification() async {
    let credential = VerifiableCredential.Mock.sample
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = credential
    refreshCredentialUseCaseSpy.callAsFunctionReturnValue = credential
    getCredentialIssuanceSummaryUseCaseSpy.callAsFunctionForThrowableError = TestingError.error

    await viewModel.refreshBatchCredential()

    XCTAssertEqual(viewModel.notificationState, .failure)
    XCTAssertFalse(viewModel.isRefreshing)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 1)
  }

  // MARK: Private

  private var getCredentialIssuanceSummaryUseCaseSpy: GetCredentialIssuanceSummaryUseCaseProtocolSpy!
  private var getCredentialRefreshThresholdUseCaseSpy: GetCredentialRefreshThresholdUseCaseProtocolSpy!
  private var getCredentialUseCaseSpy: GetCredentialUseCaseProtocolSpy!
  private var refreshCredentialUseCaseSpy: RefreshVerifiableCredentialUseCaseProtocolSpy!
  private var viewModel: IssuanceTypeViewModel!

  private var issuedAtMock: Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current

    guard let date = calendar.date(from: DateComponents(year: 2026, month: 2, day: 4, hour: 15, minute: 7)) else {
      fatalError("issuedAtMock should be a valid date")
    }

    return date
  }
}
