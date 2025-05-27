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

  func encode(_ value: some JWTPayload & Encodable, using keyPair: KeyPair) throws -> Data {
    if let encodeUsingThrowableError {
      throw encodeUsingThrowableError
    }
    receivedKeyPair = keyPair
    receivedValue = value as? U
    guard let data = encodeUsingReturnValue else { throw JWSEncoderMockError.noReturnValue }
    return data
  }
}

// swiftlint: enable force_unwrapping force_cast
#endif
