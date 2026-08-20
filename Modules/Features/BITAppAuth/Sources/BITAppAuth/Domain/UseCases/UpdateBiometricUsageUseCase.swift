import Factory
import Spyable

// MARK: - UpdateBiometricUsageUseCaseProtocol

@Spyable
public protocol UpdateBiometricUsageUseCaseProtocol {
  func callAsFunction(_ usage: BiometricUsage)
}

// MARK: - UpdateBiometricUsageUseCase

struct UpdateBiometricUsageUseCase: UpdateBiometricUsageUseCaseProtocol {

  func callAsFunction(_ usage: BiometricUsage) {
    biometricRepository.setBiometricUsage(usage)
  }

  @Injected(\.biometricRepository) private var biometricRepository: BiometricRepositoryProtocol
}
