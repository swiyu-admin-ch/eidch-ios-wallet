import Foundation
import XCTest
@testable import BITOnboarding

class SecurityIntroductionViewModelTests: XCTestCase {

  func testPrimaryAction() {
    let router = MockOnboardingInternalRoutes()
    let viewModel = SecurityIntroductionViewModel(router: router)
    viewModel.primaryAction()

    XCTAssertTrue(router.infoScreenActivitiesCalled)
  }

  func testSecondaryAction() {
    let router = MockOnboardingInternalRoutes()
    let viewModel = SecurityIntroductionViewModel(router: router)
    viewModel.secondaryAction()

    XCTAssertTrue(router.linkCalled)
  }

}
