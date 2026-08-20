#if DEBUG
import BITJWT
import Foundation

// swiftlint: disable force_cast

// MARK: - TrustStatementValidatorProtocolSpy

class TrustStatementValidatorProtocolSpy<U: TrustStatementJWT>: TrustStatementValidatorProtocol {
  var validateCallsCount = 0
  var validateThrowingError: Error?
  var validateClosure: ((JWS<U>) -> Void)?
  var validateReceivedTrustStatement: JWS<U>?

  var validateForCallsCount = 0
  var validateForThrowingError: Error?
  var validateForClosure: ((JWS<U>, String?) throws -> Void)?
  var validateForReceivedTrustStatement: JWS<U>?
  var validateForReceivedSubjectDid: String?

  func validate(_ trustStatement: BITJWT.JWS<some TrustStatementJWT>) async throws {
    validateCallsCount += 1
    validateReceivedTrustStatement = trustStatement as? JWS<U>
    if let validateThrowingError {
      throw validateThrowingError
    }
    if let closure = validateClosure {
      closure(trustStatement as! JWS<U>)
    }
  }

  func validate(_ trustStatement: BITJWT.JWS<some TrustStatementJWT>, for subjectDid: String?) async throws {
    validateForCallsCount += 1
    validateForReceivedTrustStatement = trustStatement as? JWS<U>
    validateForReceivedSubjectDid = subjectDid
    if let validateForThrowingError {
      throw validateForThrowingError
    }
    if let closure = validateForClosure, let trustStatement = trustStatement as? JWS<U> {
      try closure(trustStatement, subjectDid)
    }
  }
}

#endif
