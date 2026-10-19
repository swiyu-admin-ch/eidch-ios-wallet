import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITActivity
@testable import BITActivityDetail
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTestingCore

// MARK: - ActivityCredentialViewModelTests

@MainActor
@Suite(.container)
struct ActivityCredentialViewModelTests {

  // MARK: Internal

  @Test(arguments: ColorSchemeCase.all)
  func init_takesTheDisplayMatchingTheColorScheme(colorSchemeCase: ColorSchemeCase) throws {
    let viewModel = ActivityCredentialViewModel(detail: Self.activityDetailMock, colorScheme: colorSchemeCase.colorScheme)

    #expect(viewModel.name == "name \(colorSchemeCase.matchedTheme)")
    #expect(viewModel.summary == "summary \(colorSchemeCase.matchedTheme)")
    #expect(viewModel.backgroundColor == Self.backgroundColors[colorSchemeCase.matchedTheme])
    #expect(viewModel.logoBase64 == Data("logo \(colorSchemeCase.matchedTheme)".utf8))
    #expect(viewModel.environment == .swiyu)

    try assertClusters(of: viewModel)
  }

  @Test
  func init_noDisplay_hasNilValues() throws {
    let viewModel = ActivityCredentialViewModel(detail: ActivityDetail.Mock.noCredentialDisplays, colorScheme: "light")

    #expect(viewModel.name == nil)
    #expect(viewModel.summary == nil)
    #expect(viewModel.backgroundColor == nil)
    #expect(viewModel.logoBase64 == nil)
    #expect(viewModel.environment == .swiyu)

    try assertClusters(of: viewModel)
  }

  @Test
  func init_statusSnapshot_exposesTheStatusItHadAtActivityTime() {
    let viewModel = ActivityCredentialViewModel(detail: Self.activityDetailMock, colorScheme: "light")

    #expect(viewModel.statusListState == .revoked)
    #expect(viewModel.displayedStatus == .revoked)
    #expect(viewModel.displayedStatus?.statusText() == L10n.tkCredentialStatusRevoked)
  }

  @Test
  func init_noStatusSnapshot_exposesNoStatus() {
    let viewModel = ActivityCredentialViewModel(detail: ActivityDetail.Mock.noCredentialDisplays, colorScheme: "light")

    #expect(viewModel.statusListState == nil)
    #expect(viewModel.displayedStatus == nil)
  }

  @Test(arguments: [CredentialStatus.valid, .suspended, .revoked])
  func init_statusListState_displaysIt(statusListState: CredentialStatus) {
    let viewModel = ActivityCredentialViewModel(detail: makeDetail(statusListState: statusListState), colorScheme: "light")

    #expect(viewModel.statusListState == statusListState)
    #expect(viewModel.displayedStatus == statusListState)
  }

  @Test(arguments: [CredentialStatus.expired, .businessExpired, .notYetValid, .unsupported, .unknown])
  func init_statusOutsideTheStatusList_displaysNothing(statusListState: CredentialStatus) {
    let viewModel = ActivityCredentialViewModel(detail: makeDetail(statusListState: statusListState), colorScheme: "light")

    #expect(viewModel.statusListState == statusListState)
    #expect(viewModel.displayedStatus == nil, "\(statusListState) is not a status-list state and has nothing to show")
  }

  // MARK: Private

  private static let activityDetailMock = ActivityDetail.Mock.trustedIssuance
  private static let backgroundColors = ["dark": "#FFFFFF", "light": "#000000"]

  private func assertClusters(of viewModel: ActivityCredentialViewModel) throws {
    #expect(viewModel.clusters.count == 1)
    let cluster = try #require(viewModel.clusters.first)
    #expect(cluster.id == UUID(uuidString: "b400b56d-dd63-40f8-b036-f0f788f57212"))
    #expect(cluster.claims.count == 3)
  }

  private func makeDetail(statusListState: CredentialStatus) -> ActivityDetail {
    ActivityDetail(
      id: UUID(),
      type: .issuance,
      createdAt: Date(),
      actorDisplay: nil,
      actorTrust: .trusted,
      vcSchemaTrust: .trusted,
      actorCompliance: .compliant,
      nonComplianceReasonDisplay: nil,
      credential: ActivityDetailCredential(id: UUID(), displays: [], environment: .swiyu, clusters: [], statusListState: statusListState))
  }
}
