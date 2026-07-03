import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTheming

final class DeferredCredentialViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCaseSpy }
  }

  func testInit_inProgressCredential() {
    let viewModel = DeferredCredentialViewModel(credential: mockInProgressDeferredCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkDeferredCredentialStatusInProgress)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkDeferredCredentialStatusInProgress)

    assert(viewModel: viewModel, with: mockInProgressDeferredCredential)
  }

  func testInit_invalidCredential() {
    let viewModel = DeferredCredentialViewModel(credential: mockInvalidDeferredCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkDeferredCredentialStatusInvalid)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkDeferredCredentialStatusInvalid)

    assert(viewModel: viewModel, with: mockInvalidDeferredCredential)
  }

  func testIsRefreshable_returnsFalse() {
    let viewModel = DeferredCredentialViewModel(credential: .Mock.sample)

    XCTAssertFalse(viewModel.isRefreshable)
  }

  func testIsBatchPrivacyWarningVisible_returnsFalse() {
    let viewModel = DeferredCredentialViewModel(credential: .Mock.sample)

    XCTAssertFalse(viewModel.isBatchPrivacyWarningVisible)
  }

  // MARK: Private

  private let mockInProgressDeferredCredential = DeferredCredential.Mock.sample
  private let mockInvalidDeferredCredential = DeferredCredential.Mock.sampleInvalid
  private let getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()

  private func assert(viewModel: DeferredCredentialViewModel, with credential: DeferredCredential) {
    XCTAssertEqual(viewModel.id, credential.id)
    XCTAssertEqual(viewModel.credential, credential)
    XCTAssertEqual(viewModel.statusBadgeAccessibilityText, viewModel.statusText)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Label.secondary.swiftUIColor)
    XCTAssertEqual(viewModel.cardStyle, .deferred)

    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeCallsCount, 1)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, String())
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, mockInvalidDeferredCredential.displays)
  }

}
