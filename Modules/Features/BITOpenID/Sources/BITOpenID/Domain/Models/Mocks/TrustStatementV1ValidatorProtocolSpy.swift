#if DEBUG
import BITSdJWT
import Foundation

// swiftlint: disable force_cast

// MARK: - TrustStatementV1ValidatorProtocolSpy

class TrustStatementV1ValidatorProtocolSpy<U: TrustStatementV1JWT & Codable & Equatable>: TrustStatementV1ValidatorProtocol {

  var validateForCallsCount = 0
  var validateForReturnValue = false
  var validateForClosure: ((SdJWS<U>, String) -> Bool)?
  var validateForReceivedTrustStatement: SdJWS<U>?
  var validateForReceivedSubject: String?

  func validate(_ trustStatement: SdJWS<some TrustStatementV1JWT & Decodable>, for subject: String) async -> Bool {
    validateForCallsCount += 1
    validateForReceivedTrustStatement = trustStatement as? SdJWS<U>
    validateForReceivedSubject = subject
    if let closure = validateForClosure {
      return closure(trustStatement as! SdJWS<U>, subject)
    }
    return validateForReturnValue
  }
}

#endif
