import Factory
import Testing
@testable import BITAppAuth

struct UpdateBiometricUsageUseCaseTests {

  // MARK: Lifecycle

  init() {
    let biometricRepository = BiometricRepositoryProtocolSpy()
    Container.shared.biometricRepository.register { biometricRepository }

    self.biometricRepository = biometricRepository
    useCase = UpdateBiometricUsageUseCase()
  }

  // MARK: Internal

  @Test(arguments: [BiometricUsage.enabled, .disabled, .declined])
  func callAsFunction_persistsUsage(_ usage: BiometricUsage) {
    useCase(usage)

    #expect(biometricRepository.setBiometricUsageReceivedUsage == usage)
    #expect(biometricRepository.setBiometricUsageCallsCount == 1)
  }

  // MARK: Private

  private let biometricRepository: BiometricRepositoryProtocolSpy
  private let useCase: UpdateBiometricUsageUseCase
}
