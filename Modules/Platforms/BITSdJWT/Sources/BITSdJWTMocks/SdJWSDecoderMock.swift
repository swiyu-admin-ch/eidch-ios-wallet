#if DEBUG
import BITJWT
import Foundation
@testable import BITSdJWT

// swiftlint: disable force_unwrapping force_cast

enum SdJWSDecoderMockError: Error {
  case unexpectedInput(input: String, expected: String)
}

// MARK: - SdJWSDecoderMock

class SdJWSDecoderMock<U: Codable & Equatable>: SdJWSDecoderProtocol {

  var decodeReturnValue: SdJWS<U>?
  var receivedInput: String?
  var throwingError: Error?

  func decode<T: JWTPayload & Decodable>(_ type: T.Type, from data: Data) throws -> SdJWS<T> {
    if let throwingError {
      throw throwingError
    }
    let rawString = String(data: data, encoding: .utf8)!
    if let input = receivedInput, input != rawString {
      throw SdJWSDecoderMockError.unexpectedInput(input: rawString, expected: input)
    }
    return decodeReturnValue as! SdJWS<T>
  }
}

// swiftlint: enable force_unwrapping force_cast
#endif
