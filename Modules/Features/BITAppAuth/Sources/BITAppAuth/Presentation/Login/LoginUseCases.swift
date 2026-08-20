import BITAppInfo
import Spyable

// MARK: - LoginUseCasesProtocol

@Spyable
public protocol LoginUseCasesProtocol {
  var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol { get }
  var loginPinCode: LoginPinCodeUseCaseProtocol { get }
  var loginBiometric: LoginBiometricUseCaseProtocol { get }
  var isBiometricInvalidatedUseCase: IsBiometricInvalidatedUseCaseProtocol { get }
  var getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol { get }
  var lockWalletUseCase: LockWalletUseCaseProtocol { get }
  var unlockWalletUseCase: UnlockWalletUseCaseProtocol { get }
  var getLockedWalletTimeLeftUseCase: GetLockedWalletTimeLeftUseCaseProtocol { get }
  var getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocol { get }
  var registerLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocol { get }
  var resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol { get }
  var fetchVersionEnforcementUseCase: FetchVersionEnforcementUseCaseProtocol { get }
}

// MARK: - LoginUseCases

struct LoginUseCases: LoginUseCasesProtocol {
  let getBiometricStateUseCase: GetBiometricStateUseCaseProtocol
  let loginPinCode: LoginPinCodeUseCaseProtocol
  let loginBiometric: LoginBiometricUseCaseProtocol
  let isBiometricInvalidatedUseCase: IsBiometricInvalidatedUseCaseProtocol
  let getBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol
  let lockWalletUseCase: LockWalletUseCaseProtocol
  let unlockWalletUseCase: UnlockWalletUseCaseProtocol
  let getLockedWalletTimeLeftUseCase: GetLockedWalletTimeLeftUseCaseProtocol
  let getLoginAttemptCounterUseCase: GetLoginAttemptCounterUseCaseProtocol
  let registerLoginAttemptCounterUseCase: RegisterLoginAttemptCounterUseCaseProtocol
  let resetLoginAttemptCounterUseCase: ResetLoginAttemptCounterUseCaseProtocol
  let fetchVersionEnforcementUseCase: FetchVersionEnforcementUseCaseProtocol
}
