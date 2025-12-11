import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTheming

// swiftlint:disable implicitly_unwrapped_optional

final class VerifiableCredentialViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    getCredentialDisplayUseCase = GetCredentialDisplayUseCaseProtocolSpy()
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCase }
  }

  func testInit_withValidStatus_setsCorrectValues() {
    let viewModel = VerifiableCredentialViewModel(credential: VerifiableCredential.Mock.sample)

    XCTAssertEqual(viewModel.environment, .external)
    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusValid)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusValidAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusValid.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Label.secondary.swiftUIColor)
    XCTAssertEqual(viewModel.id, VerifiableCredential.Mock.sample.id)
  }

  func testInit_withExpiredStatus_setsCorrectValues() {
    var expiredCredential = VerifiableCredential.Mock.sample
    expiredCredential.status = .expired

    let viewModel = VerifiableCredentialViewModel(credential: expiredCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusInvalid)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusInvalidAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusInvalid.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Brand.Core.swissRed.swiftUIColor)
    XCTAssertTrue(viewModel.statusBadgeStyle is ErrorBadgeStyle)
  }

  func testInit_withUnknownStatus_setsCorrectValues() {
    var unknownCredential = VerifiableCredential.Mock.sample
    unknownCredential.status = .unknown

    let viewModel = VerifiableCredentialViewModel(credential: unknownCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusUnknown)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusUnknownAlt)
    XCTAssertEqual(viewModel.statusImage, Assets.statusUnknown.swiftUIImage)
    XCTAssertEqual(viewModel.statusColor, ThemingAssets.Label.secondary.swiftUIColor)
    XCTAssertTrue(viewModel.statusBadgeStyle is OutlineBadgeStyle)
  }

  func testInit_withNotYetValid_setsRelativeDayText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.status = .notYetValid
    notYetValidCredential.validFrom = Calendar.current.date(byAdding: .day, value: 3, to: Date())

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusNotValidYet(3))
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusNotValidYetAlt(3))
  }

  func testInit_withNotYetValidIn24Hours_setsSoonText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.status = .notYetValid
    notYetValidCredential.validFrom = Calendar.current.date(byAdding: .hour, value: 1, to: Date())

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusSoon)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusSoonAlt)
  }

  func testInit_withNilValidFrom_fallsBackToUnknownText() {
    var notYetValidCredential = VerifiableCredential.Mock.sample
    notYetValidCredential.status = .notYetValid
    notYetValidCredential.validFrom = nil

    let viewModel = VerifiableCredentialViewModel(credential: notYetValidCredential)

    XCTAssertEqual(viewModel.statusText, L10n.tkCredentialStatusUnknown)
    XCTAssertEqual(viewModel.statusTextAlt, L10n.tkCredentialStatusUnknown)
  }

  func testResolveTemplate_withMissingClaim_keepsPlaceholderEmpty() {
    getCredentialDisplayUseCase.executeForColorSchemeReturnValue = CredentialDisplay(locale: "en", summary: "Unknown: {{$.foo}}")

    let viewModel = VerifiableCredentialViewModel(credential: VerifiableCredential.Mock.sample)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Unknown: ")
  }

  func testResolveTemplate_withSingleClaim_returnsResolvedSummary() {
    getCredentialDisplayUseCase.executeForColorSchemeReturnValue = CredentialDisplay(locale: "en", summary: "Name: {{$.firstName}}")

    let viewModel = VerifiableCredentialViewModel(credential: VerifiableCredential.Mock.sample)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Name: Fritz")
  }

  func testResolveTemplate_withMultipleClaims_returnsResolvedSummary() {
    getCredentialDisplayUseCase.executeForColorSchemeReturnValue = CredentialDisplay(locale: "en", summary: "Name: {{$.firstName}} {{$.lastName}}")

    let viewModel = VerifiableCredentialViewModel(credential: VerifiableCredential.Mock.sample)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Name: Fritz Test")
  }

  func testResolveTemplate_withNullClaim_returnsSummaryWithFallback() {
    getCredentialDisplayUseCase.executeForColorSchemeReturnValue = CredentialDisplay(locale: "en", summary: "Name: {{$.firstName}}")
    let claim = CredentialClaim(key: "firstName", value: nil)
    let cluster = CredentialClaimCluster(claims: [claim])
    let credential = VerifiableCredential(payload: Data(), clusters: [cluster], format: "format", issuer: "issuer")

    let viewModel = VerifiableCredentialViewModel(credential: credential)

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "Name: –")
  }

  func testResolveTemplate_withNoTemplate_returnsSummaryAsIs() {
    getCredentialDisplayUseCase.executeForColorSchemeReturnValue = CredentialDisplay(locale: "en", summary: "summary")

    let viewModel = VerifiableCredentialViewModel(credential: VerifiableCredential.Mock.sample, colorScheme: "light")

    XCTAssertEqual(viewModel.credentialDisplay?.summary, "summary")
  }

  // MARK: Private

  private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocolSpy!
}
