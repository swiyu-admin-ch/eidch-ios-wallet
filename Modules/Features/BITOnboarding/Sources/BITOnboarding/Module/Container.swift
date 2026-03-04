import BITLocalAuthentication
import BITNavigation
import BITSettings
import Factory
import LocalAuthentication

@MainActor
extension Container {

  // MARK: Public

  public var onboardingModule: Factory<OnboardingModule> {
    self { OnboardingModule() }
  }

  // MARK: Internal

  var pinCodeInformationViewModel: ParameterFactory<OnboardingInternalRoutes, PinCodeInformationViewModel> {
    self { PinCodeInformationViewModel(router: $0) }
  }

  var pinCodeConfirmationViewModel: ParameterFactory<OnboardingInternalRoutes, PinCodeConfirmationViewModel> {
    self { PinCodeConfirmationViewModel(router: $0) }
  }

  var pinCodeViewModel: ParameterFactory<OnboardingInternalRoutes, PinCodeViewModel> {
    self { PinCodeViewModel(router: $0) }
  }

  var privacyPermissionViewModel: ParameterFactory<OnboardingInternalRoutes, PrivacyPermissionViewModel> {
    self { PrivacyPermissionViewModel(router: $0) }
  }

  var biometricsViewModel: ParameterFactory<OnboardingInternalRoutes, BiometricsViewModel> {
    self { BiometricsViewModel(router: $0) }
  }

  var setupViewModel: ParameterFactory<OnboardingInternalRoutes, SetupViewModel> {
    self { SetupViewModel(router: $0) }
  }

  var securityIntroductionViewModel: ParameterFactory<OnboardingInternalRoutes, SecurityIntroductionViewModel> {
    self { SecurityIntroductionViewModel(router: $0) }
  }

  var credentialIntroductionViewModel: ParameterFactory<OnboardingInternalRoutes, CredentialIntroductionViewModel> {
    self { CredentialIntroductionViewModel(router: $0) }
  }

  var welcomeIntroductionViewModel: ParameterFactory<OnboardingInternalRoutes, WelcomeIntroductionViewModel> {
    self { WelcomeIntroductionViewModel(router: $0) }
  }

  var internalLAContext: Factory<LAContextProtocol> {
    self { LAContext() }
  }
}

extension Container {

  // MARK: Public

  public var onboardingContext: Factory<OnboardingContext> {
    self { OnboardingContext() }
  }

  public var onboardingRouter: Factory<OnboardingRouter> {
    self { OnboardingRouter() }
  }

  // MARK: Internal

  var autoHideErrorDelay: Factory<Double> {
    self { 5 }
  }
}
