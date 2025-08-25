import BITL10n
import BITNavigation
import BITTheming
import Factory
import Spyable
import SwiftUI
import UIKit

// MARK: - OnboardingRoutes

public protocol OnboardingRoutes: ClosableRoutes {
  func onboarding()
}

extension OnboardingRoutes where Self: RouterProtocol {
  @MainActor
  public func onboarding() {
    let module = OnboardingModule()
    open(module.viewController, as: NavigationPushOpeningStyle())
  }
}

// MARK: - OnboardingInternalRoutes

protocol OnboardingInternalRoutes: ClosableRoutes {

  var context: OnboardingContext { get set }

  func infoScreenWelcome()
  func infoScreenCredential()
  func infoScreenSecurity()
  func privacyPermission()
  func pinCodeInformation()
  func pinCode()
  func pinCodeConfirmation()
  func biometrics()
  func setup()
  func completed()
  func setupError(delegate: SetupDelegate)

  func settings()
  func openExternalLink(url: URL)

}

extension OnboardingInternalRoutes where Self: RouterProtocol {

  func infoScreenWelcome() {
    let viewController = UIHostingController(rootView: WelcomeIntroductionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func infoScreenSecurity() {
    let viewController = UIHostingController(rootView: SecurityIntroductionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func infoScreenCredential() {
    let viewController = UIHostingController(rootView: CredentialIntroductionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func privacyPermission() {
    let viewController = UIHostingController(rootView: PrivacyPermissionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func pinCodeInformation() {
    let viewController = PinCodeInformationController(rootView: PinCodeInformationView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func pinCode() {
    let viewController = PinCodeHostingController(rootView: PinCodeView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func pinCodeConfirmation() {
    let viewController = PinCodeHostingController(rootView: PinCodeConfirmationView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())

    guard let navigationController = viewController.navigationController else { return }
    guard let index = navigationController.viewControllers.firstIndex(where: { $0 is PinCodeInformationController }) else { return }
    navigationController.viewControllers.removeSubrange(index + 1..<navigationController.viewControllers.count - 1)
  }

  func biometrics() {
    let viewController = UIHostingController(rootView: BiometricsView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())

    // Remove the PinCode screens from the navigation stack when getting into the biometric flow
    guard let navigationController = viewController.navigationController else { return }
    guard let index = navigationController.viewControllers.firstIndex(where: { $0 is PinCodeInformationController }) else { return }
    navigationController.viewControllers.removeSubrange(index + 1..<navigationController.viewControllers.count - 1)
  }

  func setup() {
    let viewController = HideBackButtonHostingController(rootView: SetupView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func settings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }

  func openExternalLink(url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }

  func setupError(delegate: SetupDelegate) {
    let viewController = HideBackButtonHostingController(rootView: CompletionErrorView(router: self, delegate: delegate))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  func completed() {
    let viewController = HideBackButtonHostingController(rootView: CompletionView(router: self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

}

// MARK: - OnboardingRouter

final public class OnboardingRouter: Router<UIViewController>, OnboardingRoutes, OnboardingInternalRoutes {

  // MARK: Lifecycle

  public init(context: OnboardingContext = Container.shared.onboardingContext()) {
    self.context = context
    super.init()
    current = NavigationPushOpeningStyle()
  }

  // MARK: Public

  public var context: OnboardingContext

}
