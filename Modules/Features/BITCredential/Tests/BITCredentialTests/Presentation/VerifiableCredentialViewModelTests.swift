import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTheming

final class VerifiableCredentialViewModelTests: XCTestCase {

  override class func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.isBatchIssuanceEnabled.register { true }
  }

  func testInit_withValidStatus_setsCorrectValues() {
    let viewModel = VerifiableCredentialViewModel(credential: VerifiableCredential.Mock.sample)

    XCTAssertEqual(viewModel.environment, .external)
    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusValid)
    XCTAssertEqual(viewModel.statusBadgeAccessibilityText, L10n.tkCredentialStatusValid)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusValidAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusValid.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Label.secondary.swiftUIColor)
    XCTAssertEqual(viewModel.id, VerifiableCredential.Mock.sample.id)
  }

  func testInit_withExpiredStatus_setsCorrectValues() {
    var expiredCredential = VerifiableCredential.Mock.sample
    expiredCredential.bundleItems[0].status = .expired

    let viewModel = VerifiableCredentialViewModel(credential: expiredCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusInvalid)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusInvalidAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusInvalid.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Brand.Core.swissRed.swiftUIColor)
    XCTAssertTrue(viewModel.statusBadgeStyle is ErrorBadgeStyle)
  }

  func testInit_withUnknownStatus_setsCorrectValues() {
    var unknownCredential = VerifiableCredential.Mock.sample
    unknownCredential.bundleItems[0].status = .unknown

    let viewModel = VerifiableCredentialViewModel(credential: unknownCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusUnknown)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusUnknownAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusUnknown.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Label.secondary.swiftUIColor)
    XCTAssertTrue(viewModel.statusBadgeStyle is OutlineBadgeStyle)
  }

  func testInit_withNotYetValid_setsRelativeDayText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.bundleItems[0].status = .notYetValid
    notYetValidCredential.validFrom = Calendar.current.date(byAdding: .day, value: 3, to: Date())

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusNotValidYet(3))
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusNotValidYetAlt(3))
  }

  func testInit_withNotYetValidIn24Hours_setsSoonText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.bundleItems[0].status = .notYetValid
    notYetValidCredential.validFrom = Calendar.current.date(byAdding: .hour, value: 1, to: Date())

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusSoon)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusSoonAlt)
  }

  func testInit_withNilValidFrom_fallsBackToUnknownText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.bundleItems[0].status = .notYetValid
    notYetValidCredential.validFrom = nil

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusUnknown)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusUnknown)
  }

  func testInit_withUnacceptedProgressionState_setsBadgeAccessibilityTextToProgressionState() {
    var credential = VerifiableCredential.Mock.sample
    credential.progressionState = .unaccepted

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusValid)
    XCTAssertEqual(viewModel.statusBadgeAccessibilityText, L10n.tkCredentialProgressionStateUnaccepted)
  }

  func testIsRefreshable_withRefreshToken_returnsTrue() {
    var credential = VerifiableCredential.Mock.sample
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: "refresh-token",
      dpopBinding: credential.authentication.dpopBinding)

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    XCTAssertTrue(viewModel.isRefreshable)
  }

  func testIsRefreshable_withoutRefreshToken_returnsFalse() {
    var credential = VerifiableCredential.Mock.sample
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: nil,
      dpopBinding: credential.authentication.dpopBinding)

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    XCTAssertFalse(viewModel.isRefreshable)
  }

  func testIsBatchPrivacyWarningVisible_withExhaustedBatchCredential_returnsTrue() {
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

    XCTAssertTrue(viewModel.isBatchPrivacyWarningVisible)
  }

  func testIsBatchPrivacyWarningVisible_withoutRefreshToken_returnsFalse() {
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

    XCTAssertFalse(viewModel.isBatchPrivacyWarningVisible)
  }
}
