import Foundation
import Spyable
import XCTest
@testable import BITOnboarding
@testable import BITSettings

@MainActor
final class PrivacyPermissionViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    router = OnboardingRouter()
    viewModel = PrivacyPermissionViewModel(router: router)

    XCTAssertFalse(router.context.analyticsOptIn) // Test default false on the analyticsOptIn
  }

  func testAcceptPrivacyPolicy() async {
    await viewModel.updatePrivacyPolicy(to: true)

    XCTAssertTrue(router.context.analyticsOptIn)
  }

  func testDeclinePrivacyPolicy() async {
    await viewModel.updatePrivacyPolicy(to: false)

    XCTAssertFalse(router.context.analyticsOptIn)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: PrivacyPermissionViewModel!
  private var router: OnboardingRouter!
  // swiftlint:enable all

}
