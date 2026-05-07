#if DEBUG
import Foundation

public class JWSValidatorMock<U: JWT>: JWSValidatorProtocol {

  public var validateIssuerDidActivationBufferReceivedJws: JWS<U>?
  public var validateIssuerDidActivationBufferReceivedActivationBuffer: TimeInterval?
  public var validateIssuerDidActivationBufferCallsCount = 0

  public var validateIssuerDidActivationBufferThrowableError: Error?

  public func validate(_ jws: JWS<some JWT>, activationBuffer: TimeInterval) async throws {
    validateIssuerDidActivationBufferCallsCount += 1
    validateIssuerDidActivationBufferReceivedJws = jws as? JWS<U>
    validateIssuerDidActivationBufferReceivedActivationBuffer = activationBuffer
    if let throwingError = validateIssuerDidActivationBufferThrowableError {
      throw throwingError
    }
  }

}
#endif
