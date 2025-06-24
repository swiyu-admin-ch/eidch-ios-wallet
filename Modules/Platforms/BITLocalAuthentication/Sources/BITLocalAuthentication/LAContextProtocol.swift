import Foundation
import LocalAuthentication
import Spyable

// MARK: - LAContextProtocol

@Spyable
public protocol LAContextProtocol {
  var localizedReason: String { get set }
  var interactionNotAllowed: Bool { get set }
  var biometryType: LABiometryType { get }
  func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
  func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
  func setCredential(_ credential: Data?, type: LACredentialType) -> Bool
  func isCredentialSet(_ type: LACredentialType) -> Bool
}

// MARK: - LAContext + LAContextProtocol

/// Extends LocalAuthentication `LAContext` to conform to the managed `LAContextProtocol`
/// in order to enable dependency injection and facilitate unit testing.
extension LAContext: LAContextProtocol {}
