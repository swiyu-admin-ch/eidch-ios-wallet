#if DEBUG
import Foundation

public class JWSValidatorMock<U: JWT>: JWSValidatorProtocol {

  public var validateActivationBufferReceivedJws: JWS<U>?
  public var validateActivationBufferReceivedActivationBuffer: TimeInterval?
  public var validateActivationBufferCallsCount = 0

  public var validateThrowableError: Error?

  public func validate(_ jws: JWS<some JWT>, activationBuffer: TimeInterval) async throws {
    validateActivationBufferCallsCount += 1
    validateActivationBufferReceivedJws = jws as? JWS<U>
    validateActivationBufferReceivedActivationBuffer = activationBuffer
    if let throwingError = validateThrowableError {
      throw throwingError
    }
  }

}
#endif
