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

  func testInit_noMatchingColorScheme_takesFirstDisplay() throws {
    viewModel = ActivityCredentialViewModel(detail: activityDetailMock, colorScheme: "other")

    XCTAssertEqual(viewModel.name, "name dark")
    XCTAssertEqual(viewModel.summary, "summary dark")
    XCTAssertEqual(viewModel.backgroundColor, "#FFFFFF")
    XCTAssertEqual(viewModel.logoBase64, "logo dark".data(using: .utf8))
    XCTAssertEqual(viewModel.environment, .swiyu)

    XCTAssertEqual(viewModel.clusters.count, 1)
    let cluster = try XCTUnwrap(viewModel.clusters.first)
    XCTAssertEqual(cluster.id, UUID(uuidString: "b400b56d-dd63-40f8-b036-f0f788f57212"))
    XCTAssertEqual(cluster.claims.count, 3)
  }

  func testInit_validColorScheme_takesDisplayInColorScheme() throws {
    viewModel = ActivityCredentialViewModel(detail: activityDetailMock, colorScheme: "light")

    XCTAssertEqual(viewModel.name, "name light")
    XCTAssertEqual(viewModel.summary, "summary light")
    XCTAssertEqual(viewModel.backgroundColor, "#000000")
    XCTAssertEqual(viewModel.logoBase64, "logo light".data(using: .utf8))
    XCTAssertEqual(viewModel.environment, .swiyu)

    XCTAssertEqual(viewModel.clusters.count, 1)
    let cluster = try XCTUnwrap(viewModel.clusters.first)
    XCTAssertEqual(cluster.id, UUID(uuidString: "b400b56d-dd63-40f8-b036-f0f788f57212"))
    XCTAssertEqual(cluster.claims.count, 3)
  }

  func testInit_noDisplay_hasNilValues() throws {
    viewModel = ActivityCredentialViewModel(detail: ActivityDetail.Mock.noCredentialDisplays, colorScheme: "light")

    XCTAssertNil(viewModel.name)
    XCTAssertNil(viewModel.summary)
    XCTAssertNil(viewModel.backgroundColor)
    XCTAssertNil(viewModel.logoBase64)
    XCTAssertEqual(viewModel.environment, .swiyu)

    XCTAssertEqual(viewModel.clusters.count, 1)
    let cluster = try XCTUnwrap(viewModel.clusters.first)
    XCTAssertEqual(cluster.id, UUID(uuidString: "b400b56d-dd63-40f8-b036-f0f788f57212"))
    XCTAssertEqual(cluster.claims.count, 3)
  }

  // MARK: Private

  private let activityDetailMock = ActivityDetail.Mock.trustedIssuance

  private var viewModel: ActivityCredentialViewModel!
}
