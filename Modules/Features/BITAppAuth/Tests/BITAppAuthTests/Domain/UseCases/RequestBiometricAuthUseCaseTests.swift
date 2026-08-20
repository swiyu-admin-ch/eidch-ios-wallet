import BITCore
import Factory
import Foundation
import LocalAuthentication
import OSLog
import XCTest
@testable import BITAppAuth
@testable import BITLocalAuthentication

final class RequestBiometricAuthUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    spyContext = LAContextProtocolSpy()
    useCase = RequestBiometricAuthUseCase()
  }

  func testHappyPath() async throws {
    spyContext.evaluatePolicyLocalizedReasonClosure = { _, _ in true }
    spyContext.canEvaluatePolicyErrorClosure = { _, _ in false }

    try await useCase(reason: "reason", context: spyContext)
    XCTAssertTrue(spyContext.evaluatePolicyLocalizedReasonCalled)
    XCTAssertEqual(spyContext.evaluatePolicyLocalizedReasonReceivedArguments?.policy, .deviceOwnerAuthenticationWithBiometrics)
    XCTAssertFalse(spyContext.canEvaluatePolicyErrorCalled)
    XCTAssertEqual(1, spyContext.evaluatePolicyLocalizedReasonCallsCount)
    XCTAssertEqual(0, spyContext.canEvaluatePolicyErrorCallsCount)
  }

  func testFailurePath() async throws {
    spyContext.evaluatePolicyLocalizedReasonClosure = { _, _ in false }
    spyContext.canEvaluatePolicyErrorClosure = { _, _ in false }

    do {
      try await useCase(reason: "reason", context: spyContext)
      XCTFail("Should fail instead...")
    } catch {
      XCTAssertTrue(error is AuthError)
      XCTAssertTrue(spyContext.evaluatePolicyLocalizedReasonCalled)
      XCTAssertFalse(spyContext.canEvaluatePolicyErrorCalled)
      XCTAssertEqual(1, spyContext.evaluatePolicyLocalizedReasonCallsCount)
      XCTAssertEqual(0, spyContext.canEvaluatePolicyErrorCallsCount)
    }
  }

  func testErrorPath() async throws {
    spyContext.evaluatePolicyLocalizedReasonThrowableError = AuthError.biometricNotAvailable
    spyContext.canEvaluatePolicyErrorClosure = { _, _ in false }

    do {
      _ = try await useCase(reason: "reason", context: spyContext)
      XCTFail("Should fail instead...")
    } catch {
      XCTAssertTrue(spyContext.evaluatePolicyLocalizedReasonCalled)
      XCTAssertFalse(spyContext.canEvaluatePolicyErrorCalled)
      XCTAssertEqual(1, spyContext.evaluatePolicyLocalizedReasonCallsCount)
      XCTAssertEqual(0, spyContext.canEvaluatePolicyErrorCallsCount)
    }
  }

  func testUserCancel_propagatesLAError() async {
    spyContext.evaluatePolicyLocalizedReasonThrowableError = LAError(.userCancel)

    do {
      try await useCase(reason: "reason", context: spyContext)
      XCTFail("Should fail instead...")
    } catch {
      XCTAssertEqual(error as? LAError, LAError(.userCancel))
      XCTAssertTrue(spyContext.evaluatePolicyLocalizedReasonCalled)
    }
  }

  func testUserFallback_propagatesLAError() async {
    spyContext.evaluatePolicyLocalizedReasonThrowableError = LAError(.userFallback)

    do {
      try await useCase(reason: "reason", context: spyContext)
      XCTFail("Should fail instead...")
    } catch {
      XCTAssertEqual(error as? LAError, LAError(.userFallback))
      XCTAssertTrue(spyContext.evaluatePolicyLocalizedReasonCalled)
    }
  }

  func testEvents() async {
    spyContext.evaluatePolicyLocalizedReasonClosure = { _, _ in true }
    spyContext.canEvaluatePolicyErrorClosure = { _, _ in false }

    let expectationPresented = expectation(forNotification: .permissionAlertPresented, object: nil)
    let expectationFinished = expectation(forNotification: .permissionAlertFinished, object: nil)

    try? await useCase(reason: "reason", context: spyContext)

    await fulfillment(of: [expectationPresented, expectationFinished], timeout: 2)
  }

  // MARK: Private

  private var spyContext = LAContextProtocolSpy()
  private lazy var useCase = RequestBiometricAuthUseCase()

}
