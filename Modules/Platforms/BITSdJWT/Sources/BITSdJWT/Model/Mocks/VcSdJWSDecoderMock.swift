#if DEBUG
import BITJWT
import Foundation

// swiftlint: disable force_unwrapping force_cast

// MARK: - VcSdJWSDecoderMock

class VcSdJWSDecoderMock<U: JWT>: VcSdJWSDecoderProtocol {

  // MARK: Lifecycle

  init() {}

  // MARK: Internal

  var decodeFromReturnValue: SdJWS<U>?
  var decodeFromReceivedData: Data?
  var decodeFromThrowableError: Error?
  var decodeFromClosure: ((Data) throws -> SdJWS<U>)?

  func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> SdJWS<T> {
    decodeFromReceivedData = data
    if let decodeFromThrowableError {
      throw decodeFromThrowableError
    }
    if let decodeFromClosure {
      return try decodeFromClosure(data) as! SdJWS<T>
    }
    return decodeFromReturnValue as! SdJWS<T>
  }
}
#endif
