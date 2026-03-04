import BITLocalAuthentication
import Factory
import Foundation
import LocalAuthentication
import Spyable

// MARK: - UserSessionError

public enum UserSessionError: Error {
  case notLoggedIn
}

// MARK: - Session

@Spyable
public protocol Session {

  /// Indicates whether the user is currently logged in.
  var isLoggedIn: Bool { get }

  /// Provides the authentication context associated with the session.
  /// This can be `nil` if no session is active.
  var context: LAContextProtocol? { get }

  /// Sets the passphrase on a newly created LAContext, which will start a session.
  ///
  /// This method configures an authentication context with a credential,
  /// enabling secure operations requiring authentication.
  ///
  /// - Parameters:
  ///   - passphrase: Passphrase data that will be securely stored in the authentication context.
  ///   - credentialType: The type of credential, typically `.applicationPassword`, used for authentication.
  ///
  /// - Returns: The configured authentication context (`LAContextProtocol`).
  /// - Throws: `AuthError.LAContextError` if setting the credential fails.
  @discardableResult
  func startSession(passphrase: Data, credentialType: LACredentialType) throws -> LAContextProtocol

  /// Ends the current authentication session and clears the authentication context.
  ///
  /// This method should be called when the session is no longer needed to release
  /// authentication-related resources and prevent unauthorized access.
  func endSession()
}

extension Session {
  @discardableResult
  public func startSession(
    passphrase: Data,
    credentialType: LACredentialType = .applicationPassword) throws
    -> LAContextProtocol
  {
    try startSession(passphrase: passphrase, credentialType: credentialType)
  }
}

// MARK: - UserSession

public class UserSession: Session {

  public private(set) var context: (any LAContextProtocol)?

  public var isLoggedIn: Bool {
    context?.isCredentialSet(.applicationPassword) ?? false
  }

  @discardableResult
  public func startSession(
    passphrase: Data,
    credentialType: LACredentialType = .applicationPassword) throws
    -> LAContextProtocol
  {
    let localContext = Container.shared.internalContext()
    guard localContext.setCredential(passphrase, type: credentialType) else {
      throw AuthError.LAContextError(reason: "Error while trying to set the type \(credentialType) to the LAContext")
    }
    context = localContext
    return localContext
  }

  public func endSession() {
    context = nil
    Container.shared.internalContext.reset()
  }

}
