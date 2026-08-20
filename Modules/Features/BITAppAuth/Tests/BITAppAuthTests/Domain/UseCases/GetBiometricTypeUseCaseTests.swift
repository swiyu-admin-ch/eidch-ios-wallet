import Factory
import Foundation
import LocalAuthentication
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// MARK: - GetBiometricTypeUseCaseTests

final class GetBiometricTypeUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    useCase = GetBiometricTypeUseCase()
    success()
  }

  func testExecute_argumentsPassed() {
    _ = useCase()

    XCTAssertEqual(policyValidatorSpy.validatePolicyContextReceivedArguments?.policy, .deviceOwnerAuthenticationWithBiometrics)
  }

  func testExecute_faceID_returnsFaceID() {
    contextSpy.biometryType = .faceID

    let result = useCase()

    XCTAssertEqual(result, .faceID)
  }

  func testExecute_touchID_returnsTouchID() {
    contextSpy.biometryType = .touchID

    let result = useCase()

    XCTAssertEqual(result, .touchID)
  }

  func testExecute_none_returnsNone() {
    contextSpy.biometryType = .none

    let result = useCase()

    XCTAssertEqual(result, .none)
  }

  func testExecute_policyIsNotValid_returnsNone() {
    policyValidatorSpy.validatePolicyContextReturnValue = false

    let result = useCase()

    XCTAssertEqual(result, .none)
  }

  func testExecute_policyThrowsError_returnsNone() {
    policyValidatorSpy.validatePolicyContextThrowableError = TestingError.error

    let result = useCase()

    XCTAssertEqual(result, .none)
  }

  // MARK: Private

  // swiftlint:disable all
  private var contextSpy: LAContextProtocolSpy!
  private var policyValidatorSpy: LocalAuthenticationPolicyValidatorProtocolSpy!
  private var useCase: GetBiometricTypeUseCase!

  // swiftlint:enable all

  private func registerMocks() {
    policyValidatorSpy = LocalAuthenticationPolicyValidatorProtocolSpy()
    contextSpy = LAContextProtocolSpy()
    Container.shared.localAuthenticationPolicyValidator.register { self.policyValidatorSpy }
    Container.shared.internalContext.register { self.contextSpy }
  }

  private func success() {
    policyValidatorSpy.validatePolicyContextReturnValue = true
    contextSpy.biometryType = .faceID
  }
}
