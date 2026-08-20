import Factory
import LocalAuthentication
import Testing
@testable import BITAppAuth
@testable import BITLocalAuthentication

@MainActor
struct GetBiometricStateUseCaseTests {

  // MARK: Lifecycle

  init() {
    let biometricRepository = BiometricRepositoryProtocolSpy()
    let context = LAContextProtocolSpy()
    let validator = LocalAuthenticationPolicyValidatorProtocolSpy()

    Container.shared.biometricRepository.register { biometricRepository }
    Container.shared.internalContext.register { context }
    Container.shared.localAuthenticationPolicyValidator.register { validator }

    self.biometricRepository = biometricRepository
    self.context = context
    self.validator = validator

    getBiometricStateUseCase = GetBiometricStateUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_biometricsUnavailable_returnsDeclined() {
    validator.validatePolicyContextReturnValue = false

    #expect(getBiometricStateUseCase() == .declined)
    #expect(biometricRepository.getBiometricUsageCalled == false)
  }

  @Test
  func callAsFunction_biometricsNotEnrolled_returnsNotEnrolled() {
    validator.validatePolicyContextThrowableError = LAError(LAError.Code.biometryNotEnrolled)

    #expect(getBiometricStateUseCase() == .notEnrolled)
    #expect(biometricRepository.getBiometricUsageCalled == false)
  }

  @Test
  func callAsFunction_policyEvaluationFails_returnsDeclined() {
    validator.validatePolicyContextThrowableError = LAError(LAError.Code.passcodeNotSet)

    #expect(getBiometricStateUseCase() == .declined)
    #expect(biometricRepository.getBiometricUsageCalled == false)
  }

  // MARK: Private

  private let biometricRepository: BiometricRepositoryProtocolSpy
  private let context: LAContextProtocolSpy
  private let validator: LocalAuthenticationPolicyValidatorProtocolSpy
  private let getBiometricStateUseCase: GetBiometricStateUseCase
}
