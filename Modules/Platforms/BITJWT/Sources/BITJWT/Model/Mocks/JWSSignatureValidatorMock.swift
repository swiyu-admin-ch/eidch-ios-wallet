#if DEBUG

public class JWSSignatureValidatorMock<U: JWT>: JWSSignatureValidatorProtocol {

  public var validateReceivedJws: JWS<U>?
  public var validateCallsCount = 0

  public var validateThrowableError: Error?

  public func validate(_ jws: JWS<some JWT>) async throws {
    validateCallsCount += 1
    validateReceivedJws = jws as? JWS<U>
    if let throwingError = validateThrowableError {
      throw throwingError
    }
  }

}
#endif
