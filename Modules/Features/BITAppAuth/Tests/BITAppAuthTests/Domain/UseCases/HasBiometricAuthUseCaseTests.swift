import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITTestingCore

final class HasBiometricAuthUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    useCase = HasBiometricAuthUseCase()
  }

  func testExecute_argumentsArePassed() {
    policyValidatorSpy.validatePolicyContextReturnValue = true

    _ = useCase.execute()

    XCTAssertEqual(policyValidatorSpy.validatePolicyContextReceivedArguments?.policy, .deviceOwnerAuthenticationWithBiometrics)
  }

  func testExecute_policyIsValid_returnsTrue() {
    policyValidatorSpy.validatePolicyContextReturnValue = true

    let result = useCase.execute()

    XCTAssertTrue(result)
  }

  func testExecute_policyIsNotValid_returnsFalse() {
    policyValidatorSpy.validatePolicyContextReturnValue = false

    let result = useCase.execute()

    XCTAssertFalse(result)
  }

  func testExecute_policyThrowsError_returnsFalse() {
    policyValidatorSpy.validatePolicyContextThrowableError = TestingError.error

    let result = useCase.execute()

    XCTAssertFalse(result)
  }

  // MARK: Private

  // swiftlint:disable all
  private var policyValidatorSpy: LocalAuthenticationPolicyValidatorProtocolSpy!
  private var contextSpy: LAContextProtocolSpy!
  private var useCase: HasBiometricAuthUseCase!

  // swiftlint:enable all

  private func registerMocks() {
    policyValidatorSpy = LocalAuthenticationPolicyValidatorProtocolSpy()
    contextSpy = LAContextProtocolSpy()
    Container.shared.localAuthenticationPolicyValidator.register { self.policyValidatorSpy }
    Container.shared.internalContext.register { self.contextSpy }
  }

}
