// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITActivityDetail
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

@MainActor
final class ActivityCredentialViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testInit_activityWithClaims_clustersAvailable() throws {
    viewModel = ActivityCredentialViewModel(credential: credentialMock, activity: activityMock)

    XCTAssertNotNil(viewModel.name)
    XCTAssertNotNil(viewModel.summary)
    XCTAssertNotNil(viewModel.backgroundColor)
    XCTAssertNotNil(viewModel.logoBase64)
    XCTAssertEqual(viewModel.environment, .external)

    XCTAssertEqual(viewModel.clusters.count, 1)
    let cluster = try XCTUnwrap(viewModel.clusters.first)
    XCTAssertEqual(cluster.claims.count, 1)
    XCTAssertEqual(cluster.claims.first?.id.uuidString, "416A2EC2-213B-438C-B9DA-47A2FF596A0C")
    XCTAssertTrue(cluster.childClusters.isEmpty)
  }

  func testInit_activityNoClaims_noClusters() {
    let activityMock = Activity.Mock.presentationAcceptedTrusted
    viewModel = ActivityCredentialViewModel(credential: credentialMock, activity: activityMock)

    XCTAssertNotNil(viewModel.name)
    XCTAssertNotNil(viewModel.summary)
    XCTAssertNotNil(viewModel.backgroundColor)
    XCTAssertNotNil(viewModel.logoBase64)
    XCTAssertEqual(viewModel.environment, .external)

    XCTAssertTrue(viewModel.clusters.isEmpty == true)
  }

  // MARK: Private

  private let activityMock = Activity.Mock.issueTrusted
  private let credentialMock = VerifiableCredential.Mock.sample

  private var viewModel: ActivityCredentialViewModel!
}
