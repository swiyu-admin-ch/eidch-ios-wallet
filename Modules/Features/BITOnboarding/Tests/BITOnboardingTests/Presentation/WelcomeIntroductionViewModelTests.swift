import Foundation
import Testing
@testable import BITOnboarding

@MainActor
struct WelcomeIntroductionViewModelTests {

  @Test
  func testPrimaryAction() {
    let router = MockOnboardingInternalRoutes()
    let viewModel = WelcomeIntroductionViewModel(router: router)
    viewModel.primaryAction()

    #expect(router.infoScreenSecurityCalled)
  }

}
