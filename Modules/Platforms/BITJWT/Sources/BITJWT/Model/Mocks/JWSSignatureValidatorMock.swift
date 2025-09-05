#if DEBUG
import XCTest

public class JWSSignatureValidatorMock<U: Codable & Equatable>: JWSSignatureValidatorProtocol {

  public var validateIssuerDidReturnValue = false

  public var validateIssuerDidReceivedJws: JWS<U>?
  public var validateIssuerDidReceivedDid: String?
  public var validateIssuerDidCallsCount = 0

  public var validateIssuerDidThrowableError: Error?

  public func validate(_ jws: some JWS<some Codable & Equatable>, issuerDid: String) async throws -> Bool {
    validateIssuerDidCallsCount += 1
    validateIssuerDidReceivedJws = jws as? JWS<U>
    validateIssuerDidReceivedDid = issuerDid
    if let throwingError = validateIssuerDidThrowableError {
      throw throwingError
    }
    return validateIssuerDidReturnValue
  }

}
#endif
