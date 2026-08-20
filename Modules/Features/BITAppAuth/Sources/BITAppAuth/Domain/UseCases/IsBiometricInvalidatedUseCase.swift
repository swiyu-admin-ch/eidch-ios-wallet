import Factory
import Spyable

// MARK: - IsBiometricInvalidatedUseCaseProtocol

@Spyable
public protocol IsBiometricInvalidatedUseCaseProtocol {
  func callAsFunction() -> Bool
}

// MARK: - IsBiometricInvalidatedUseCase

struct IsBiometricInvalidatedUseCase: IsBiometricInvalidatedUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() -> Bool {
    let exists = uniquePassphraseManager.exists(for: .biometric)
    return getBiometricStateUseCase() == .enabled && !exists
  }

  // MARK: Private

  @Injected(\.getBiometricStateUseCase) private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol
  @Injected(\.uniquePassphraseManager) private var uniquePassphraseManager: UniquePassphraseManagerProtocol
}
