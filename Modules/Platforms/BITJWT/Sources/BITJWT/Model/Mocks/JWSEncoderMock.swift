#if DEBUG
import Foundation
@testable import BITCrypto

// MARK: - JWSEncoderMockError

// swiftlint: disable force_unwrapping force_cast

enum JWSEncoderMockError: Error {
  case noReturnValue
}

// MARK: - JWSEncoderMock

class JWSEncoderMock<U: Codable & Equatable>: JWSEncoderProtocol {

  var encodeUsingReturnValue: Data? = nil
  var receivedKeyPair: KeyPair? = nil
  var receivedValue: U? = nil
  var encodeUsingThrowableError: Error? = nil
  var encodeReturnValue: JWS<U>? = nil

  func encode(_ value: some JWTPayload & Encodable, using keyPair: KeyPair) throws -> Data {
    if let encodeUsingThrowableError {
      throw encodeUsingThrowableError
    }
    receivedKeyPair = keyPair
    receivedValue = value as? U
    guard let data = encodeUsingReturnValue else { throw JWSEncoderMockError.noReturnValue }
    return data
  }

  func encode<T>(_ value: T, keyPair: KeyPair) throws -> JWS<T> where T: JWTPayload, T: Decodable, T: Encodable, T: Equatable {
    if let encodeUsingThrowableError {
      throw encodeUsingThrowableError
    }
    receivedKeyPair = keyPair
    receivedValue = value as? U
    guard let jws = encodeReturnValue else { throw JWSEncoderMockError.noReturnValue }

    return jws as! JWS<T>
  }
}

// swiftlint: enable force_unwrapping force_cast
#endif
