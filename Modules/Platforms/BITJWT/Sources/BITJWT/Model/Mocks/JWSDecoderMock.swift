#if DEBUG
import Foundation

// swiftlint: disable force_unwrapping force_cast

enum JWSDecoderMockError: Error {
  case unexpectedInput(input: String, expected: String)
}

// MARK: - JWSDecoderMock

struct JWSDecoderMock<U: Codable & Equatable>: JWSDecoderProtocol {

  var payload: U?
  var rawPayload: String?
  var header = JWSHeader(algorithm: JWTAlgorithm.ES256)
  var expectedInput: String?
  var throwingError: Error?

  func decode<T: JWTPayload & Decodable>(_ type: T.Type, from data: Data) throws -> JWS<T> {
    if let throwingError {
      throw throwingError
    }
    let rawString = String(data: data, encoding: .utf8)!
    if let input = expectedInput, input != rawString {
      throw JWSDecoderMockError.unexpectedInput(input: rawString, expected: input)
    }
    let jws = JWS(payload: payload!, rawPayload: rawPayload ?? "rawPayload", rawJWS: rawString, header: header)
    return jws as! JWS<T>
  }
}

// swiftlint: enable force_unwrapping force_cast
#endif
