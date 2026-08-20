import Factory
import FactoryTesting
import Testing
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTheming

@Suite(.container)
struct DeferredCredentialViewModelTests {

  // MARK: Lifecycle

  init() {
    let getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()
    self.getCredentialDisplayUseCaseSpy = getCredentialDisplayUseCaseSpy
    Container.shared.getCredentialDisplayUseCase.register { getCredentialDisplayUseCaseSpy }
  }

  // MARK: Internal

  @Test
  func init_inProgressCredential_setsCorrectValues() {
    let viewModel = DeferredCredentialViewModel(credential: mockInProgressDeferredCredential)

    #expect(viewModel.statusText == L10n.tkDeferredCredentialStatusInProgress)
    #expect(viewModel.statusTextAlt == L10n.tkDeferredCredentialStatusInProgress)

    assert(viewModel: viewModel, with: mockInProgressDeferredCredential)
  }

  @Test
  func init_invalidCredential_setsCorrectValues() {
    let viewModel = DeferredCredentialViewModel(credential: mockInvalidDeferredCredential)

    #expect(viewModel.statusText == L10n.tkDeferredCredentialStatusInvalid)
    #expect(viewModel.statusTextAlt == L10n.tkDeferredCredentialStatusInvalid)

    assert(viewModel: viewModel, with: mockInvalidDeferredCredential)
  }

  @Test
  func isRefreshable_returnsFalse() {
    let viewModel = DeferredCredentialViewModel(credential: .Mock.sample)

    #expect(!viewModel.isRefreshable)
  }

  @Test
  func isBatchPrivacyWarningVisible_returnsFalse() {
    let viewModel = DeferredCredentialViewModel(credential: .Mock.sample)

    #expect(!viewModel.isBatchPrivacyWarningVisible)
  }

  // MARK: Private

  private let mockInProgressDeferredCredential = DeferredCredential.Mock.sample
  private let mockInvalidDeferredCredential = DeferredCredential.Mock.sampleInvalid
  private let getCredentialDisplayUseCaseSpy: GetCredentialDisplayUseCaseProtocolSpy

  private func assert(viewModel: DeferredCredentialViewModel, with credential: DeferredCredential) {
    #expect(viewModel.id == credential.id)
    #expect(viewModel.credential == credential)
    #expect(viewModel.statusBadgeAccessibilityText == viewModel.statusText)
    #expect(viewModel.statusColor == ThemingAssets.Label.secondary.swiftUIColor)
    #expect(viewModel.cardStyle == .deferred)

    #expect(getCredentialDisplayUseCaseSpy.executeForColorSchemeCallsCount == 1)
    #expect(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme == String())
    #expect(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays == credential.displays)
  }
}
