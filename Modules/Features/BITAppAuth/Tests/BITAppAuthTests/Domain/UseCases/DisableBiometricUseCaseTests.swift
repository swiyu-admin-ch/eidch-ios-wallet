import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITAppAuth
@testable import BITTestingCore

@Suite(.container)
struct DisableBiometricUseCaseTests {

  // MARK: Lifecycle

  init() {
    let uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()
    self.uniquePassphraseManager = uniquePassphraseManager

    let updateBiometricUsageUseCase = UpdateBiometricUsageUseCaseProtocolSpy()
    self.updateBiometricUsageUseCase = updateBiometricUsageUseCase

    Container.shared.uniquePassphraseManager.register { uniquePassphraseManager }
    Container.shared.updateBiometricUsageUseCase.register { updateBiometricUsageUseCase }

    useCase = DisableBiometricUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_deletesPassphraseAndSetsUsageDisabled() throws {
    try useCase()

    #expect(uniquePassphraseManager.deleteBiometricUniquePassphraseCalled)
    #expect(updateBiometricUsageUseCase.callAsFunctionReceivedUsage == .disabled)
  }

  @Test
  func callAsFunction_deleteThrows_rethrowsAndDoesNotUpdateUsage() {
    uniquePassphraseManager.deleteBiometricUniquePassphraseThrowableError = TestingError.error

    #expect(throws: TestingError.self) {
      try useCase()
    }
    #expect(!updateBiometricUsageUseCase.callAsFunctionCalled)
  }

  // MARK: Private

  private let useCase: DisableBiometricUseCase
  private let uniquePassphraseManager: UniquePassphraseManagerProtocolSpy
  private let updateBiometricUsageUseCase: UpdateBiometricUsageUseCaseProtocolSpy

}
