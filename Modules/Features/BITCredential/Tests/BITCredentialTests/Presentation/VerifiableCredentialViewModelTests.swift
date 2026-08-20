import BITCore
import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTheming

@Suite(.container)
struct VerifiableCredentialViewModelTests {

  // MARK: Lifecycle

  init() {
    Container.shared.isBatchIssuanceEnabled.register { true }
    Container.shared.currentDate.register { Self.currentDate }
  }

  // MARK: Internal

  @Test
  func init_withValidStatus_setsCorrectValues() {
    let credential = VerifiableCredential.Mock.sample
    let viewModel = VerifiableCredentialViewModel(credential: credential)

    #expect(viewModel.environment == .external)
    #expect(viewModel.statusText == L10n.tkCredentialStatusValid)
    #expect(viewModel.statusBadgeAccessibilityText == L10n.tkCredentialStatusValid)
    #expect(viewModel.statusTextAlt == L10n.tkCredentialStatusValidAlt)
    #expect(viewModel.statusImage == Assets.statusValid.swiftUIImage)
    #expect(viewModel.statusColor == ThemingAssets.Label.secondary.swiftUIColor)
    #expect(viewModel.id == VerifiableCredential.Mock.sample.id)
  }

  @Test
  func init_withExpiredStatus_setsCorrectValues() {
    var expiredCredential = VerifiableCredential.Mock.sample
    expiredCredential.bundleItems[0].status = .expired

    let viewModel = VerifiableCredentialViewModel(credential: expiredCredential)

    #expect(viewModel.statusText == L10n.tkCredentialStatusInvalid)
    #expect(viewModel.statusTextAlt == L10n.tkCredentialStatusInvalidAlt)
    #expect(viewModel.statusImage == Assets.statusInvalid.swiftUIImage)
    #expect(viewModel.statusColor == ThemingAssets.Brand.Core.swissRed.swiftUIColor)
    #expect(viewModel.statusBadgeStyle is ErrorBadgeStyle)
  }

  @Test
  func init_withUnknownStatus_setsCorrectValues() {
    var unknownCredential = VerifiableCredential.Mock.sample
    unknownCredential.bundleItems[0].status = .unknown

    let viewModel = VerifiableCredentialViewModel(credential: unknownCredential)

    #expect(viewModel.statusText == L10n.tkCredentialStatusUnknown)
    #expect(viewModel.statusTextAlt == L10n.tkCredentialStatusUnknownAlt)
    #expect(viewModel.statusImage == Assets.statusUnknown.swiftUIImage)
    #expect(viewModel.statusColor == ThemingAssets.Label.secondary.swiftUIColor)
    #expect(viewModel.statusBadgeStyle is OutlineBadgeStyle)
  }

  @Test
  func init_withNotYetValidOnDifferentDay_setsDateText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.bundleItems[0].status = .notYetValid
    let validFrom = Date.create(2026, 7, 26, 8, 15, 0)
    notYetValidCredential.validFrom = validFrom

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)
    let expectedDate = DateFormatter.shortDateFormatter.string(from: validFrom)

    #expect(viewModel.statusText == L10n.tkCredentialStatusNotYetValid(expectedDate))
    #expect(viewModel.statusTextAlt == L10n.tkCredentialStatusNotYetValidAlt(expectedDate))
  }

  @Test
  func init_withNotYetValidOnSameDay_setsTimeText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.bundleItems[0].status = .notYetValid
    let validFrom = Date.create(2026, 7, 23, 13, 13, 0)
    notYetValidCredential.validFrom = validFrom

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)
    let expectedTime = DateFormatter.shortHourFormatter.string(from: validFrom)

    #expect(viewModel.statusText == L10n.tkCredentialStatusValidAt(expectedTime))
    #expect(viewModel.statusTextAlt == L10n.tkCredentialStatusValidAtAlt(expectedTime))
  }

  @Test
  func init_withNilValidFrom_fallsBackToUnknownText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.bundleItems[0].status = .notYetValid
    notYetValidCredential.validFrom = nil

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)

    #expect(viewModel.statusText == L10n.tkCredentialStatusUnknown)
    #expect(viewModel.statusTextAlt == L10n.tkCredentialStatusUnknownAlt)
  }

  @Test
  func init_withUnacceptedProgressionState_setsBadgeAccessibilityTextToProgressionState() {
    var credential = VerifiableCredential.Mock.sample
    credential.progressionState = .unaccepted

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    #expect(viewModel.statusText == L10n.tkCredentialStatusValid)
    #expect(viewModel.statusBadgeAccessibilityText == L10n.tkCredentialProgressionStateUnaccepted)
  }

  @Test
  func isRefreshable_withRefreshToken_returnsTrue() {
    var credential = VerifiableCredential.Mock.sample
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: "refresh-token",
      dpopBinding: credential.authentication.dpopBinding)

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    #expect(viewModel.isRefreshable)
  }

  @Test
  func isRefreshable_withoutRefreshToken_returnsFalse() {
    var credential = VerifiableCredential.Mock.sample
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: nil,
      dpopBinding: credential.authentication.dpopBinding)

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    #expect(!viewModel.isRefreshable)
  }

  @Test
  func isBatchPrivacyWarningVisible_withExhaustedBatchCredential_returnsTrue() {
    var credential = VerifiableCredential.Mock.sample
    credential.batchData = BatchData(batchSize: 2)
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: "refresh-token",
      dpopBinding: credential.authentication.dpopBinding)
    if credential.bundleItems.count == 1 {
      credential.bundleItems.append(BundleItem(payload: Data("second".utf8)))
    }
    credential.bundleItems = credential.bundleItems.map {
      var item = $0
      item.presented = true
      return item
    }

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    #expect(viewModel.isBatchPrivacyWarningVisible)
  }

  @Test
  func isBatchPrivacyWarningVisible_withoutRefreshToken_returnsFalse() {
    var credential = VerifiableCredential.Mock.sample
    credential.batchData = BatchData(batchSize: 2)
    if credential.bundleItems.count == 1 {
      credential.bundleItems.append(BundleItem(payload: Data("second".utf8)))
    }
    credential.bundleItems = credential.bundleItems.map {
      var item = $0
      item.presented = true
      return item
    }
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: nil,
      dpopBinding: credential.authentication.dpopBinding)

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    #expect(!viewModel.isBatchPrivacyWarningVisible)
  }

  // MARK: Private

  private static let currentDate = Date.create(2026, 7, 23, 10, 13, 0)
}
