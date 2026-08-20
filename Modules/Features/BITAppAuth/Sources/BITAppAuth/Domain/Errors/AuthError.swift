import Foundation

public enum AuthError: Error, Equatable {
  case LAContextError(reason: String)
  case missingUniquePassphrase

  case biometricPolicyEvaluationFailed
  case biometricNotAvailable

  // MARK: Public

  public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
    switch (lhs, rhs) {
    case (.LAContextError(let lhsReason), .LAContextError(let rhsReason)):
      lhsReason == rhsReason
    case (.missingUniquePassphrase, .missingUniquePassphrase):
      true
    case (.biometricPolicyEvaluationFailed, .biometricPolicyEvaluationFailed):
      true
    case (.biometricNotAvailable, .biometricNotAvailable):
      true
    default:
      false
    }
  }
}
