import Factory
import FactoryTesting
import Foundation
import LocalAuthentication
import Testing
@testable import BITAppAuth
@testable import BITLocalAuthentication

@Suite(.container)
struct ChangeBiometricStatusUseCaseTests {

  // MARK: Lifecycle

  init() {
    let requestBiometricAuthUseCase = RequestBiometricAuthUseCaseProtocolSpy()
    self.requestBiometricAuthUseCase = requestBiometricAuthUseCase

    let uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()
    self.uniquePassphraseManager = uniquePassphraseManager

    let updateBiometricUsageUseCase = UpdateBiometricUsageUseCaseProtocolSpy()
    self.updateBiometricUsageUseCase = updateBiometricUsageUseCase

    let disableBiometricUseCase = DisableBiometricUseCaseProtocolSpy()
    self.disableBiometricUseCase = disableBiometricUseCase

    let getBiometricStateUseCase = GetBiometricStateUseCaseProtocolSpy()
    self.getBiometricStateUseCase = getBiometricStateUseCase

    let userSession = SessionSpy()
    self.userSession = userSession

    Container.shared.requestBiometricAuthUseCase.register { requestBiometricAuthUseCase }
    Container.shared.uniquePassphraseManager.register { uniquePassphraseManager }
    Container.shared.updateBiometricUsageUseCase.register { updateBiometricUsageUseCase }
    Container.shared.disableBiometricUseCase.register { disableBiometricUseCase }
    Container.shared.getBiometricStateUseCase.register { getBiometricStateUseCase }
    Container.shared.userSession.register { userSession }

    useCase = ChangeBiometricStatusUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_biometricEnabled_disablesBiometrics() async throws {
    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()
    getBiometricStateUseCase.callAsFunctionReturnValue = .enabled

    try await useCase(with: mockData)

    #expect(disableBiometricUseCase.callAsFunctionCalled)
  }

  @Test
  func callAsFunction_biometricDisabled_enablesBiometrics() async throws {
    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()
    getBiometricStateUseCase.callAsFunctionReturnValue = .disabled

    try await useCase(with: mockData)

    #expect(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextCalled)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextReceivedArguments?.authMethod == .biometric)
    #expect(uniquePassphraseManager.saveUniquePassphraseForContextReceivedArguments?.uniquePassphrase == mockData)
    #expect(updateBiometricUsageUseCase.callAsFunctionReceivedUsage == .enabled)
  }

  @Test
  func callAsFunction_enableCancelled_throwsUserCancelAndKeepsBiometricsDisabled() async {
    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()
    getBiometricStateUseCase.callAsFunctionReturnValue = .disabled
    requestBiometricAuthUseCase.callAsFunctionReasonContextThrowableError = LAError(LAError.Code.userCancel)

    await #expect(throws: ChangeBiometricStatusError.userCancel) {
      try await useCase(with: mockData)
    }

    #expect(requestBiometricAuthUseCase.callAsFunctionReasonContextCalled)
    #expect(!uniquePassphraseManager.saveUniquePassphraseForContextCalled)
    #expect(!updateBiometricUsageUseCase.callAsFunctionCalled)
  }

  // MARK: Private

  private let useCase: ChangeBiometricStatusUseCase
  private let requestBiometricAuthUseCase: RequestBiometricAuthUseCaseProtocolSpy
  private let uniquePassphraseManager: UniquePassphraseManagerProtocolSpy
  private let updateBiometricUsageUseCase: UpdateBiometricUsageUseCaseProtocolSpy
  private let disableBiometricUseCase: DisableBiometricUseCaseProtocolSpy
  private let getBiometricStateUseCase: GetBiometricStateUseCaseProtocolSpy
  private let userSession: SessionSpy

  private let mockData = Data()

}
