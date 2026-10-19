import Foundation
import Testing
@testable import BITOnboarding

@MainActor
struct SecurityIntroductionViewModelTests {

  @Test
  func primaryAction() {
    let router = MockOnboardingInternalRoutes()
    let viewModel = SecurityIntroductionViewModel(router: router)
    viewModel.primaryAction()

    #expect(router.infoScreenActivitiesCalled)
  }

  @Test
  func secondaryAction() {
    let router = MockOnboardingInternalRoutes()
    let viewModel = SecurityIntroductionViewModel(router: router)
    viewModel.secondaryAction()

    #expect(router.linkCalled)
  }

}
