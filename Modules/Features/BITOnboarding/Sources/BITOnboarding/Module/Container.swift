import BITLocalAuthentication
import BITNavigation
import BITSettings
import Factory
import LocalAuthentication

@MainActor
extension Container {

  // MARK: Public

  public var onboardingModule: Factory<OnboardingModule> {
    self { @MainActor in OnboardingModule() }
  }

  // MARK: Internal

  var pinCodeInformationViewModel: ParameterFactory<OnboardingInternalRoutes, PinCodeInformationViewModel> {
    self { @MainActor in PinCodeInformationViewModel(router: $0) }
  }

  var pinCodeConfirmationViewModel: ParameterFactory<OnboardingInternalRoutes, PinCodeConfirmationViewModel> {
    self { @MainActor in PinCodeConfirmationViewModel(router: $0) }
  }

  var pinCodeViewModel: ParameterFactory<OnboardingInternalRoutes, PinCodeViewModel> {
    self { @MainActor in PinCodeViewModel(router: $0) }
  }

  var privacyPermissionViewModel: ParameterFactory<OnboardingInternalRoutes, PrivacyPermissionViewModel> {
    self { @MainActor in PrivacyPermissionViewModel(router: $0) }
  }

  var biometricsViewModel: ParameterFactory<OnboardingInternalRoutes, BiometricsViewModel> {
    self { @MainActor in BiometricsViewModel(router: $0) }
  }

  var setupViewModel: ParameterFactory<OnboardingInternalRoutes, SetupViewModel> {
    self { @MainActor in SetupViewModel(router: $0) }
  }

  var securityIntroductionViewModel: ParameterFactory<OnboardingInternalRoutes, SecurityIntroductionViewModel> {
    self { @MainActor in SecurityIntroductionViewModel(router: $0) }
  }

  var credentialIntroductionViewModel: ParameterFactory<OnboardingInternalRoutes, CredentialIntroductionViewModel> {
    self { @MainActor in CredentialIntroductionViewModel(router: $0) }
  }

  var welcomeIntroductionViewModel: ParameterFactory<OnboardingInternalRoutes, WelcomeIntroductionViewModel> {
    self { @MainActor in WelcomeIntroductionViewModel(router: $0) }
  }

  var internalLAContext: Factory<LAContextProtocol> {
    self { @MainActor in LAContext() }
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
