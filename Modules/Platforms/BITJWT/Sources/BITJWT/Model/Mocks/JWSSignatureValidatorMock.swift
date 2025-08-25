#if DEBUG
import XCTest

public class JWSSignatureValidatorMock: JWSSignatureValidatorProtocol {

  public var validateJwsDidReturnValue = false

  public var validateJwsDidReceivedJws: JWSValidatable?
  public var validateJwsDidReceivedDid: String?

  public var validateJwsDidThrowableError: Error?

  public func validate(_ jws: JWSValidatable, did: String) async throws -> Bool {
    validateJwsDidReceivedJws = jws
    validateJwsDidReceivedDid = did
    if let throwingError = validateJwsDidThrowableError {
      throw throwingError
    }
    return validateJwsDidReturnValue
  }

}
#endif
