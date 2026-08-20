import Factory
import Spyable

// MARK: - DisableBiometricUseCaseProtocol

@Spyable
protocol DisableBiometricUseCaseProtocol {
  func callAsFunction() throws
}

// MARK: - DisableBiometricUseCase

struct DisableBiometricUseCase: DisableBiometricUseCaseProtocol {

  func callAsFunction() throws {
    try uniquePassphraseManager.deleteBiometricUniquePassphrase()
    updateBiometricUsageUseCase(.disabled)
  }

  @Injected(\.uniquePassphraseManager) private var uniquePassphraseManager: UniquePassphraseManagerProtocol
  @Injected(\.updateBiometricUsageUseCase) private var updateBiometricUsageUseCase: UpdateBiometricUsageUseCaseProtocol
}
