import BITCrypto
import BITLocalAuthentication
import BITVault
import Factory
import LocalAuthentication
import SwiftUI

@MainActor
extension Container {

  // MARK: Public

  public var loginModule: Factory<LoginModule> {
    self { @MainActor in LoginModule() }
  }

  public var noDevicePinCodeModule: Factory<NoDevicePinCodeModule> {
    self { @MainActor in NoDevicePinCodeModule() }
  }

  // MARK: Internal

  var loginViewModel: ParameterFactory<LoginRouterRoutes, LoginViewModel> {
    self { @MainActor in LoginViewModel(router: $0) }
  }

  var changePinCodeModule: Factory<ChangePinCodeModule> {
    self { @MainActor in ChangePinCodeModule() }
  }

  var changePinCodeContext: Factory<ChangePinCodeContext> {
    self { @MainActor in ChangePinCodeContext() }
  }

  var changePinCodeRouter: Factory<ChangePinCodeRouter> {
    self { @MainActor in ChangePinCodeRouter() }
  }

  var currentPinCodeViewModel: ParameterFactory<ChangePinCodeInternalRoutes, CurrentPinCodeViewModel> {
    self { @MainActor in CurrentPinCodeViewModel(router: $0) }
  }

  var newPinCodeViewModel: ParameterFactory<ChangePinCodeInternalRoutes, NewPinCodeViewModel> {
    self { @MainActor in NewPinCodeViewModel(router: $0) }
  }

  var confirmPinCodeViewModel: ParameterFactory<ChangePinCodeInternalRoutes, ConfirmPinCodeViewModel> {
    self { @MainActor in ConfirmPinCodeViewModel(router: $0) }
  }

  var biometricChangeModule: Factory<BiometricChangeModule> {
    self { @MainActor in BiometricChangeModule() }
  }

  var biometricChangeViewModel: ParameterFactory<BiometricChangeRouterRoutes, BiometricChangeViewModel> {
    self { @MainActor in BiometricChangeViewModel(router: $0) }
  }

  var biometricChangeRouter: Factory<BiometricChangeRouter> {
    self { @MainActor in BiometricChangeRouter() }
  }

  var noDevicePinCodeViewModel: ParameterFactory<NoDevicePinCodeRouterRoutes, NoDevicePinCodeViewModel> {
    self { @MainActor in NoDevicePinCodeViewModel(router: $0) }
  }

}

extension Container {

  public var loginRouter: Factory<LoginRouter> {
    self { LoginRouter() }
  }

  public var noDevicePinRouter: Factory<NoDevicePinCodeRouter> {
    self { NoDevicePinCodeRouter() }
  }

}

// MARK: - Managers

extension Container {

  // MARK: Public

  public var pinCodeErrorAnimationDuration: Factory<CGFloat> {
    self { 0.5 }
  }

  public var awaitTimeBeforeBiometrics: Factory<UInt64> {
    self { 325_000_000 }
  }

  public var pinCodeObserverDelay: Factory<CGFloat> {
    self { 0.1 }
  }

  public var loadingDelay: Factory<UInt64> {
    self { 1_000_000_000 }
  }

  public var loginRequiredIntervalThreshold: Factory<TimeInterval> {
    self { 5 }
  }

  public var pinCodeSize: Factory<Int> {
    self { 6 }
  }

  public var pinCodeMinimumSize: Factory<Int> {
    self { 6 }
  }

  public var pinCodeErrorAuthHideDelay: Factory<Double> {
    self { 5 }
  }

  public var attemptsLimit: Factory<Int> {
    self { 5 }
  }

  public var attemptsLimitChangePinCode: Factory<Int> {
    self { 3 }
  }

  public var lockDelay: Factory<TimeInterval> {
    self { 60 * 5 }
  }

  /// Length In byte
  public var passphraseLength: Factory<Int> {
    self { 64 }
  }

  public var uniquePassphraseManager: Factory<UniquePassphraseManagerProtocol> {
    self { UniquePassphraseManager() }
  }

  public var localAuthenticationPolicyValidator: Factory<LocalAuthenticationPolicyValidatorProtocol> {
    self { LocalAuthenticationPolicyValidator() }
  }

  public var userSession: Factory<Session> {
    self { UserSession() }.singleton
  }

  public var internalContext: Factory<LAContextProtocol> {
    #if targetEnvironment (simulator)
    self { SimulatorLAContext() }
    #else
    self { LAContext() }.singleton // LAContext should be a singleton since having too many of them, can lead to an error
    #endif
  }

  public var pepperKeyVaultOptions: Factory<VaultOptions> {
    self { .secureEnclavePermanently }
  }

  // MARK: Internal

  var pinCodeService: Factory<PinCodeServiceProtocol> {
    self { PinCodeService() }
  }

  var authCredentialType: Factory<LACredentialType> {
    self { .applicationPassword }
  }

  var keyDeriver: Factory<KeyDerivable> {
    self { PBKDF2(using: .hmacSHA512) }
  }

  var encrypter: Factory<Encryptable> {
    self { AESEncrypter() }
  }

  /// Length In byte
  var encrypterLength: Factory<Int> {
    self { 32 }
  }

  /// Length In byte
  var appPinSaltLength: Factory<Int> {
    self { 16 }
  }

  /// Length In byte
  var pepperKeyInitialVectorLength: Factory<Int> {
    self { 12 }
  }

  var pepperKeyDerivationAlgorithm: Factory<SecKeyAlgorithm> {
    self { .ecdhKeyExchangeStandardX963SHA256 }
  }

  var pepperKeyAlgorithm: Factory<VaultAlgorithm> {
    self { .eciesEncryptionStandardVariableIVX963SHA256AESGCM }
  }

  var appPepperKeyRepository: Factory<AppPepperKeyRepositoryProtocol> {
    self { AppPepperKeyRepository() }
  }
}

// MARK: - Repository

extension Container {

  // MARK: Public

  public var biometricRepository: Factory<BiometricRepositoryProtocol> {
    self { UserDefaultBiometricRepository() }
  }

  // MARK: Internal

  var pinCodeSecretStore: Factory<PinCodeSecretStoreProtocol> {
    self { PinCodeRepository() }
  }

  var uniquePassphraseRepository: Factory<UniquePassphraseRepositoryProtocol> {
    self { UniquePassphraseRepository() }
  }

  var lockWalletRepository: Factory<LockWalletRepositoryProtocol> {
    self { LockWalletRepository() }
  }

  var loginRepository: Factory<LoginRepositoryProtocol> {
    self { LoginRepository() }
  }

}

// MARK: - UseCases

extension Container {

  // MARK: Public

  public var hasDevicePinUseCase: Factory<HasDevicePinUseCaseProtocol> {
    self {
      HasDevicePinUseCase()
    }
  }

  public var isUserLoggedInUseCase: Factory<IsUserLoggedInUseCaseProtocol> {
    self { IsUserLoggedInUseCase() }
  }

  public var registerPinCodeUseCase: Factory<RegisterPinCodeUseCaseProtocol> {
    self { RegisterPinCodeUseCase() }
  }

  public var getBiometricTypeUseCase: Factory<GetBiometricTypeUseCaseProtocol> {
    self { GetBiometricTypeUseCase() }
  }

  public var hasBiometricAuthUseCase: Factory<HasBiometricAuthUseCaseProtocol> {
    self { HasBiometricAuthUseCase() }
  }

  public var requestBiometricAuthUseCase: Factory<RequestBiometricAuthUseCaseProtocol> {
    self { RequestBiometricAuthUseCase() }
  }

  public var updatePinCodeUseCase: Factory<UpdatePinCodeUseCaseProtocol> {
    self { UpdatePinCodeUseCase() }
  }

  public var getUniquePassphraseUseCase: Factory<GetUniquePassphraseUseCaseProtocol> {
    self { GetUniquePassphraseUseCase() }
  }

  public var validatePinCodeRuleUseCase: Factory<ValidatePinCodeRuleUseCaseProtocol> {
    self { ValidatePinCodeRuleUseCase() }
  }

  public var loginUseCases: Factory<LoginUseCasesProtocol> {
    self {
      LoginUseCases(
        getBiometricStateUseCase: self.getBiometricStateUseCase(),
        loginPinCode: self.loginPinCodeUseCase(),
        loginBiometric: self.loginBiometricUseCase(),
        isBiometricInvalidatedUseCase: self.isBiometricInvalidatedUseCase(),
        getBiometricTypeUseCase: self.getBiometricTypeUseCase(),
        lockWalletUseCase: self.lockWalletUseCase(),
        unlockWalletUseCase: self.unlockWalletUseCase(),
        getLockedWalletTimeLeftUseCase: self.getLockedWalletTimeLeftUseCase(),
        getLoginAttemptCounterUseCase: self.getLoginAttemptCounterUseCase(),
        registerLoginAttemptCounterUseCase: self.registerLoginAttemptCounterUseCase(),
        resetLoginAttemptCounterUseCase: self.resetLoginAttemptCounterUseCase(),
        fetchVersionEnforcementUseCase: self.fetchVersionEnforcementUseCase())
    }
  }

  public var resetLoginAttemptCounterUseCase: Factory<ResetLoginAttemptCounterUseCaseProtocol> {
    self { ResetLoginAttemptCounterUseCase() }
  }

  public var unlockWalletUseCase: Factory<UnlockWalletUseCaseProtocol> {
    self { UnlockWalletUseCase() }
  }

  public var loginPinCodeUseCase: Factory<LoginPinCodeUseCaseProtocol> {
    self { LoginPinCodeUseCase() }
  }

  public var updateBiometricUsageUseCase: Factory<UpdateBiometricUsageUseCaseProtocol> {
    self { UpdateBiometricUsageUseCase() }
  }

  public var getBiometricStateUseCase: Factory<GetBiometricStateUseCaseProtocol> {
    self { GetBiometricStateUseCase() }
  }

  // MARK: Internal

  var loginBiometricUseCase: Factory<LoginBiometricUseCaseProtocol> {
    self { LoginBiometricUseCase() }
  }

  var changeBiometricStatusUseCase: Factory<ChangeBiometricStatusUseCaseProtocol> {
    self { ChangeBiometricStatusUseCase() }
  }

  var isBiometricInvalidatedUseCase: Factory<IsBiometricInvalidatedUseCaseProtocol> {
    self { IsBiometricInvalidatedUseCase() }
  }

  var lockWalletUseCase: Factory<LockWalletUseCaseProtocol> {
    self { LockWalletUseCase() }
  }

  var getLockedWalletTimeLeftUseCase: Factory<GetLockedWalletTimeLeftUseCaseProtocol> {
    self { GetLockedWalletTimeLeftUseCase() }
  }

  var getLoginAttemptCounterUseCase: Factory<GetLoginAttemptCounterUseCaseProtocol> {
    self { GetLoginAttemptCounterUseCase() }
  }

  var registerLoginAttemptCounterUseCase: Factory<RegisterLoginAttemptCounterUseCaseProtocol> {
    self { RegisterLoginAttemptCounterUseCase() }
  }

  var disableBiometricUseCase: Factory<DisableBiometricUseCaseProtocol> {
    self { DisableBiometricUseCase() }
  }

}
