import Foundation
import Testing
@testable import BITOnboarding

@MainActor
struct CredentialIntroductionViewModelTests {

  @Test
  func primaryAction() {
    let router = MockOnboardingInternalRoutes()
    let viewModel = CredentialIntroductionViewModel(router: router)
    viewModel.primaryAction()

    #expect(router.privacyPermissionCalled)
  }

}
