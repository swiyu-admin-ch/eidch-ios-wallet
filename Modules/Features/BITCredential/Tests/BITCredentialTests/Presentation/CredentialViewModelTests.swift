import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTheming

final class CredentialViewModelTests: XCTestCase {

  func testInit_withValidStatus_setsCorrectValues() {
    let viewModel = CredentialViewModel(credential: Credential.Mock.sample, credentialDisplay: nil)

    XCTAssertEqual(viewModel.environment, .none)
    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusValid)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusValidAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusValid.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Label.secondary.swiftUIColor)
    XCTAssertEqual(viewModel.id, Credential.Mock.sample.id)
  }

  func testInit_withExpiredStatus_setsCorrectValues() {
    var expiredCredential = Credential.Mock.sample
    expiredCredential.status = .expired

    let viewModel = CredentialViewModel(credential: expiredCredential, credentialDisplay: nil)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusInvalid)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusInvalidAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusInvalid.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Brand.Core.swissRed.swiftUIColor)
    XCTAssertTrue(viewModel.statusBadgeStyle is ErrorBadgeStyle)
  }

  func testInit_withUnknownStatus_setsCorrectValues() {
    var unknownCredential = Credential.Mock.sample
    unknownCredential.status = .unknown

    let viewModel = CredentialViewModel(credential: unknownCredential, credentialDisplay: nil)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusUnknown)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusUnknownAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusUnknown.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Label.secondary.swiftUIColor)
    XCTAssertTrue(viewModel.statusBadgeStyle is OutlineBadgeStyle)
  }

  func testInit_withNotYetValid_setsRelativeDayText() {
    var notYetValidCredential = Credential.Mock.sample
    notYetValidCredential.status = .notYetValid
    notYetValidCredential.validFrom = Calendar.current.date(byAdding: .day, value: 3, to: Date())

    let viewModel = CredentialViewModel(credential: notYetValidCredential, credentialDisplay: nil)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusNotValidYet(3))
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusNotValidYetAlt(3))
  }

  func testInit_withNotYetValidIn24Hours_setsSoonText() {
    var notYetValidCredential = Credential.Mock.sample
    notYetValidCredential.status = .notYetValid
    notYetValidCredential.validFrom = Calendar.current.date(byAdding: .hour, value: 1, to: Date())

    let viewModel = CredentialViewModel(credential: notYetValidCredential, credentialDisplay: nil)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusSoon)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusSoonAlt)
  }

  func testInit_withNilValidFrom_fallsBackToUnknownText() {
    var notYetValidCredential = Credential.Mock.sample
    notYetValidCredential.status = .notYetValid
    notYetValidCredential.validFrom = nil

    let viewModel = CredentialViewModel(credential: notYetValidCredential, credentialDisplay: nil)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusUnknown)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusUnknown)
  }

  func testResolveTemplate_withMissingClaim_keepsPlaceholderEmpty() {
    let credentialDisplay = CredentialDisplay(locale: "en", summary: "Unknown: {{$.foo}}")

    let viewModel = CredentialViewModel(credential: Credential.Mock.sample, credentialDisplay: credentialDisplay)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Unknown: ")
  }

  func testResolveTemplate_withSingleClaim_returnsResolvedSummary() {
    let credentialDisplay = CredentialDisplay(locale: "en", summary: "Name: {{$.firstName}}")

    let viewModel = CredentialViewModel(credential: Credential.Mock.sample, credentialDisplay: credentialDisplay)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Name: Fritz")
  }

  func testResolveTemplate_withMultipleClaims_returnsResolvedSummary() {
    let credentialDisplay = CredentialDisplay(locale: "en", summary: "Name: {{$.firstName}} {{$.lastName}}")

    let viewModel = CredentialViewModel(credential: Credential.Mock.sample, credentialDisplay: credentialDisplay)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Name: Fritz Test")
  }

  func testResolveTemplate_withNullClaim_returnsSummaryWithFallback() {
    let credentialDisplay = CredentialDisplay(locale: "en", summary: "Name: {{$.firstName}}")
    let claim = CredentialClaim(key: "firstName", value: nil)
    let cluster = CredentialClaimCluster(claims: [claim])
    let credential = Credential(payload: Data(), format: "format", issuer: "issuer", clusters: [cluster])

    let viewModel = CredentialViewModel(credential: credential, credentialDisplay: credentialDisplay)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Name: –")
  }

  func testResolveTemplate_withNoTemplate_returnsSummaryAsIs() {
    let credentialDisplay = CredentialDisplay(locale: "en", summary: "summary")

    let viewModel = CredentialViewModel(credential: Credential.Mock.sample, credentialDisplay: credentialDisplay)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "summary")
  }
}
