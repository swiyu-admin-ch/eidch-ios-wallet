import BITL10n
import Factory
import Foundation
import Spyable
import Testing
@testable import BITAppInfo

struct VersionEnforcementViewModelTests {

  // MARK: Lifecycle

  init() {
    let versionEnforcementRouter = VersionEnforcementRouterMock()
    let versionEnforcementDelegate = VersionEnforcementDelegateSpy()
    let getAppVersionUseCase = GetAppVersionUseCaseProtocolSpy()
    getAppVersionUseCase.callAsFunctionReturnValue = Version.Mock.sample

    Container.shared.getAppVersionUseCase.register { getAppVersionUseCase }

    viewModel = VersionEnforcementViewModel(router: versionEnforcementRouter, versionEnforcement: .Mock.forced, delegate: versionEnforcementDelegate)
    self.versionEnforcementRouter = versionEnforcementRouter
    self.versionEnforcementDelegate = versionEnforcementDelegate
    self.getAppVersionUseCase = getAppVersionUseCase
  }

  // MARK: Internal

  @Test(arguments: [
    VersionEnforcement.Mock.noDisplay,
    VersionEnforcement.Mock.blacklistedDevice,
    VersionEnforcement.Mock.outdatedOsVersion,
    VersionEnforcement.Mock.optional,
    VersionEnforcement.Mock.forced,
  ])
  mutating func initialState(for enforcement: VersionEnforcement) {
    viewModel = VersionEnforcementViewModel(router: versionEnforcementRouter, versionEnforcement: enforcement, delegate: versionEnforcementDelegate)

    #expect(viewModel.enforcementType == enforcement.type)
    #expect(viewModel.message == enforcement.messages.findDisplayWithFallback())
  }

  @Test
  func dismissToHomeScreen() {
    viewModel.dismissToHomeScreen()

    #expect(versionEnforcementRouter.closeWithCompletionCalled == true)
    #expect(versionEnforcementDelegate.didDismissVersionEnforcementCalled == true)
  }

  // MARK: Private

  private var viewModel: VersionEnforcementViewModel
  private let versionEnforcementRouter: VersionEnforcementRouterMock
  private let versionEnforcementDelegate: VersionEnforcementDelegateSpy
  private let getAppVersionUseCase: GetAppVersionUseCaseProtocolSpy
}
