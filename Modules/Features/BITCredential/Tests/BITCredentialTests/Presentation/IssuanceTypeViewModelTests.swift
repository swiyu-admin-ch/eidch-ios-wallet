import BITCore
import Factory
import Foundation
import XCTest
@testable import BITCredential
@testable import BITCredentialShared

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

    viewModel = IssuanceTypeViewModel(credentialId: VerifiableCredential.Mock.sample.id)
  }

  func testOnAppear_refreshesCredentialFromDatabase() async {
    getCredentialIssuanceSummaryUseCaseSpy.executeForReturnValue = CredentialIssuanceSummary(issuedAt: issuedAtMock, available: 1, total: 1)

    await viewModel.onAppear()

    guard case .result(.single, let timeStamp) = viewModel.state else {
      return XCTFail("Expected result state")
    }

    XCTAssertEqual(timeStamp, "04.02.2026 | 15:07")
    XCTAssertEqual(getCredentialIssuanceSummaryUseCaseSpy.executeForReceivedCredentialId, VerifiableCredential.Mock.sample.id)
  }

  func testOnAppear_updatesAvailableBatchCount() async {
    getCredentialIssuanceSummaryUseCaseSpy.executeForReturnValue = CredentialIssuanceSummary(
      issuedAt: issuedAtMock,
      available: 0,
      total: 2)

    await viewModel.onAppear()

    guard case .result(.batch(let batchViewModel), _) = viewModel.state else {
      return XCTFail("Expected batch issuance type")
    }

    XCTAssertEqual(batchViewModel.available, 0)
    XCTAssertEqual(batchViewModel.total, 2)
  }

  func testOnAppear_withBatchCredentialUsesRefreshThresholdUseCase() async {
    getCredentialIssuanceSummaryUseCaseSpy.executeForReturnValue = CredentialIssuanceSummary(
      issuedAt: issuedAtMock,
      available: 7,
      total: 10)
    getCredentialRefreshThresholdUseCaseSpy.callAsFunctionForReturnValue = 4

    await viewModel.onAppear()

    guard case .result(.batch(let batchViewModel), _) = viewModel.state else {
      return XCTFail("Expected batch issuance type")
    }

    XCTAssertEqual(batchViewModel.available, 7)
    XCTAssertEqual(batchViewModel.total, 10)
    XCTAssertEqual(batchViewModel.refreshThreshold, 4)
    XCTAssertEqual(getCredentialRefreshThresholdUseCaseSpy.callAsFunctionForReceivedBatchSize, 10)
  }

  // MARK: Private

  private var getCredentialIssuanceSummaryUseCaseSpy: GetCredentialIssuanceSummaryUseCaseProtocolSpy!
  private var getCredentialRefreshThresholdUseCaseSpy: GetCredentialRefreshThresholdUseCaseProtocolSpy!
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
