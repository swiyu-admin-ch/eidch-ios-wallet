import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTheming

final class VerifiableCredentialViewModelTests: XCTestCase {

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
}
