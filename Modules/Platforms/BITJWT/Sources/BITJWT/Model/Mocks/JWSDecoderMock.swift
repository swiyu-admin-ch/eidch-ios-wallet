#if DEBUG
import Foundation

// swiftlint: disable force_unwrapping force_cast

enum JWSDecoderMockError: Error {
  case unexpectedInput(input: String, expected: String)
}

// MARK: - JWSDecoderMock

struct JWSDecoderMock<U: Codable & Equatable>: JWSDecoderProtocol {

  // MARK: Lifecycle

  init(payload: U, rawPayload: String) {
    self.payload = payload
    self.rawPayload = rawPayload
  }

  // MARK: Internal

  var payload: U
  var rawPayload: String
  var expectedInput: String? = nil
  var throwingError: Error? = nil

  func decode<T: JWTPayload & Decodable>(_ type: T.Type, from data: Data) throws -> JWS<T> {
    if let throwingError {
      throw throwingError
    }
    let rawString = String(data: data, encoding: .utf8)!
    if let input = expectedInput, input != rawString {
      throw JWSDecoderMockError.unexpectedInput(input: rawString, expected: input)
    }
    let jws = JWS(payload: payload, rawJWS: rawString, rawPayload: rawPayload, header: JWSHeader(algorithm: JWTAlgorithm.ES256))
    return jws as! JWS<T>
  }
}

// swiftlint: enable force_unwrapping force_cast
#endif
