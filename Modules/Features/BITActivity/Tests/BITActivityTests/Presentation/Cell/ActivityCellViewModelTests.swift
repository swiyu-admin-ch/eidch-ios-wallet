// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITTestingCore

@MainActor
final class ActivityCellViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setenv("TZ", "UTC", 1)
    CFTimeZoneResetSystem()
  }

  override func tearDown() {
    unsetenv("TZ")
    CFTimeZoneResetSystem()
  }

  func testTimeStamp_German() {
    Container.shared.preferredUserLocales.register { ["de-CH"] }
    viewModel = ActivityCellViewModel(activity: Activity.Mock.issueTrusted)

    XCTAssertEqual(viewModel.timeStamp, "16.09.2025 | 13:20")
  }

  func testTimeStamp_English() {
    Container.shared.preferredUserLocales.register { ["en-US"] }
    viewModel = ActivityCellViewModel(activity: Activity.Mock.issueTrusted)

    XCTAssertEqual(viewModel.timeStamp, "09/16/2025 | 01:20 PM")
  }

  // MARK: Private

  private var viewModel: ActivityCellViewModel!

}
