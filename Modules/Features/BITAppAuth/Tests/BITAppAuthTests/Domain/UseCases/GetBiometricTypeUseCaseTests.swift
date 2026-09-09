import Factory
import FactoryTesting
import LocalAuthentication
import Testing
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITTestingCore

@Suite(.container)
struct GetBiometricTypeUseCaseTests {

  // MARK: Lifecycle

  init() {
    let policyValidatorSpy = LocalAuthenticationPolicyValidatorProtocolSpy()
    let contextSpy = LAContextProtocolSpy()

    Container.shared.localAuthenticationPolicyValidator.register { policyValidatorSpy }
    Container.shared.internalContext.register { contextSpy }

    self.policyValidatorSpy = policyValidatorSpy
    self.contextSpy = contextSpy

    policyValidatorSpy.validatePolicyContextReturnValue = true
    contextSpy.biometryType = .faceID

    useCase = GetBiometricTypeUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_argumentsPassed() {
    _ = useCase()

    #expect(policyValidatorSpy.validatePolicyContextReceivedArguments?.policy == .deviceOwnerAuthenticationWithBiometrics)
  }

  @Test
  func callAsFunction_faceID_returnsFaceID() {
    contextSpy.biometryType = .faceID

    #expect(useCase() == .faceID)
  }

  @Test
  func callAsFunction_touchID_returnsTouchID() {
    contextSpy.biometryType = .touchID

    #expect(useCase() == .touchID)
  }

  @Test
  func callAsFunction_none_returnsNone() {
    contextSpy.biometryType = .none

    #expect(useCase() == .none)
  }

  @Test
  func callAsFunction_policyIsNotValid_returnsNone() {
    policyValidatorSpy.validatePolicyContextReturnValue = false

    #expect(useCase() == .none)
  }

  @Test
  func callAsFunction_policyThrowsError_returnsNone() {
    policyValidatorSpy.validatePolicyContextThrowableError = TestingError.error

    #expect(useCase() == .none)
  }

  // MARK: Private

  private let contextSpy: LAContextProtocolSpy
  private let policyValidatorSpy: LocalAuthenticationPolicyValidatorProtocolSpy
  private let useCase: GetBiometricTypeUseCase
}
