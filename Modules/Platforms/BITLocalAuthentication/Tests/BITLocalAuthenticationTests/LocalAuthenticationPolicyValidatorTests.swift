import XCTest
@testable import BITLocalAuthentication

final class LocalAuthenticationPolicyValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    contextSpy = LAContextProtocolSpy()
    validator = LocalAuthenticationPolicyValidator()
  }

  func testValidatePolicy_argumentsPassed() throws {
    let policy = LocalAuthenticationPolicy.deviceOwnerAuthenticationWithBiometrics
    contextSpy.canEvaluatePolicyErrorReturnValue = true

    _ = try validator.validatePolicy(policy, context: contextSpy)
    XCTAssertEqual(policy, contextSpy.canEvaluatePolicyErrorReceivedArguments?.policy)
  }

  func testValidatePolicy_policyIsValid_returnsTrue() throws {
    let policy = LocalAuthenticationPolicy.deviceOwnerAuthenticationWithBiometrics
    contextSpy.canEvaluatePolicyErrorReturnValue = true

    let result = try validator.validatePolicy(policy, context: contextSpy)

    XCTAssertTrue(result)
  }

  func testValidatePolicy_policyIsNotValid_returnsFalse() throws {
    let policy = LocalAuthenticationPolicy.deviceOwnerAuthenticationWithBiometrics
    contextSpy.canEvaluatePolicyErrorReturnValue = false

    let result = try validator.validatePolicy(policy, context: contextSpy)

    XCTAssertFalse(result)
  }

  // MARK: Private

  // swiftlint:disable all
  private var contextSpy: LAContextProtocolSpy!
  private var validator: LocalAuthenticationPolicyValidator!
  // swiftlint:enable all

}
