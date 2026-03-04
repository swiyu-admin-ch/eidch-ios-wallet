import Factory
import LocalAuthentication
import XCTest
@testable import BITAppAuth
@testable import BITLocalAuthentication

// MARK: - UserSessionTests

final class UserSessionTests: XCTestCase {

  // MARK: Internal

  // MARK: - Test: Start Session Success

  override func setUp() {
    super.setUp()
    localContext = LAContextProtocolSpy()
    Container.shared.internalContext.register { self.localContext }
  }

  func test_startSession_success() throws {
    let session = UserSession()

    localContext.setCredentialTypeReturnValue = true
    localContext.isCredentialSetReturnValue = true

    try session.startSession(
      passphrase: passphrase,
      credentialType: .applicationPassword)

    XCTAssertTrue(session.isLoggedIn, "Session should be logged in after successful startSession.")
    XCTAssertNotNil(session.context, "Session context should be set upon success.")
  }

  // MARK: - Test: Start Session Failure

  func test_startSession_failure() {
    let session = UserSession()

    localContext.setCredentialTypeReturnValue = false
    localContext.isCredentialSetReturnValue = false

    XCTAssertThrowsError(
      try session.startSession(
        passphrase: passphrase,
        credentialType: .applicationPassword))
    { error in
      guard let authError = error as? AuthError else {
        XCTFail("Expected AuthError but got: \(error)")
        return
      }
      switch authError {
      case .LAContextError(let reason):
        XCTAssertTrue(reason.contains("trying to set the type"))
      default:
        XCTFail("Should fail with LAContextError.")
      }
    }

    XCTAssertFalse(session.isLoggedIn, "Session should not be logged in when startSession fails.")
    XCTAssertNil(session.context, "Session context should remain nil after failure.")
  }

  // MARK: - Test: endSession

  func test_endSession() throws {
    let session = UserSession()

    localContext.setCredentialTypeReturnValue = true
    localContext.isCredentialSetReturnValue = true

    try session.startSession(
      passphrase: passphrase,
      credentialType: .applicationPassword)
    XCTAssertTrue(session.isLoggedIn)

    session.endSession()

    XCTAssertFalse(session.isLoggedIn, "Session should be logged out after endSession.")
    XCTAssertNil(session.context, "Context should be cleared after endSession.")
  }

  // MARK: Private

  // swiftlint:disable all
  private var localContext: LAContextProtocolSpy!
  private let passphrase: Data = "Secret".data(using: .utf8)!
  // swiftlint:enable all

}
