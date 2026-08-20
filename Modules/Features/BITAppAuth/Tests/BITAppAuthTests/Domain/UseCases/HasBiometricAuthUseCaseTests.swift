import Factory
import FactoryTesting
import Testing
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITTestingCore

@Suite(.container)
struct HasBiometricAuthUseCaseTests {

  // MARK: Lifecycle

  init() {
    let context = LAContextProtocolSpy()
    let validator = LocalAuthenticationPolicyValidatorProtocolSpy()

    Container.shared.internalContext.register { context }
    Container.shared.localAuthenticationPolicyValidator.register { validator }

    self.context = context
    self.validator = validator
    useCase = HasBiometricAuthUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_argumentsArePassed() {
    validator.validatePolicyContextReturnValue = true

    _ = useCase()

    #expect(validator.validatePolicyContextReceivedArguments?.policy == .deviceOwnerAuthenticationWithBiometrics)
  }

  @Test
  func callAsFunction_policyIsValid_returnsTrue() {
    validator.validatePolicyContextReturnValue = true

    let result = useCase()

    #expect(result)
  }

  @Test
  func callAsFunction_policyIsNotValid_returnsFalse() {
    validator.validatePolicyContextReturnValue = false

    let result = useCase()

    #expect(!result)
  }

  @Test
  func callAsFunction_policyThrowsError_returnsFalse() {
    validator.validatePolicyContextThrowableError = TestingError.error

    let result = useCase()

    #expect(!result)
  }

  // MARK: Private

  private let context: LAContextProtocolSpy
  private let validator: LocalAuthenticationPolicyValidatorProtocolSpy
  private let useCase: HasBiometricAuthUseCase
}
