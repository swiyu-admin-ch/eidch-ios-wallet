import BITCore
import Factory
import Foundation
import Testing
@testable import BITAppAuth

struct IsBiometricInvalidatedUseCaseTests {

  // MARK: Lifecycle

  init() {
    let uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()
    self.uniquePassphraseManager = uniquePassphraseManager

    let getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    self.getBiometricStateUseCase = getBiometricStateUseCase

    Container.shared.getBiometricStateUseCase.register { getBiometricStateUseCase }
    Container.shared.uniquePassphraseManager.register { uniquePassphraseManager }

    useCase = IsBiometricInvalidatedUseCase()
  }

  // MARK: Internal

  @Test(arguments: [true, false])
  func callAsFunction_biometricsEnabled(_ passphraseExists: Bool) {
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled
    uniquePassphraseManager.existsForReturnValue = passphraseExists

    #expect(useCase() == !passphraseExists)
    #expect(getBiometricStateUseCase.callAsFunctionCallsCount == 1)
    #expect(uniquePassphraseManager.existsForCallsCount == 1)
    #expect(uniquePassphraseManager.existsForReceivedAuthMethod == .biometric)
  }

  @Test(arguments: [BiometricState.disabled, .declined, .notEnrolled])
  func callAsFunction_biometricsNotEnabled_returnsFalse(_ biometricState: BiometricState) {
    getBiometricStateUseCase.callAsFunctionReturnValue = biometricState
    uniquePassphraseManager.existsForReturnValue = false

    #expect(useCase() == false)
    #expect(getBiometricStateUseCase.callAsFunctionCallsCount == 1)
    #expect(uniquePassphraseManager.existsForCallsCount == 1)
  }

  // MARK: Private

  private let useCase: IsBiometricInvalidatedUseCase
  private let uniquePassphraseManager: UniquePassphraseManagerProtocolSpy
  private let getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy

}
