#if DEBUG
import Foundation
@testable import BITCrypto

// MARK: - JWSEncoderMockError

// swiftlint: disable force_unwrapping force_cast

enum JWSEncoderMockError: Error {
  case noReturnValue
  case unexpectedKeyPair(input: KeyPair, expected: KeyPair)
}

// MARK: - JWSEncoderMock

struct JWSEncoderMock<U: Codable & Equatable>: JWSEncoderProtocol {

  // MARK: Internal

  var encodeUsingReturnValue: Data? = nil
  var expectedKeyPair: KeyPair? = nil
  var encodeUsingThrowableError: Error? = nil

  func encode(_ value: some JWTPayload & Encodable, using keyPair: KeyPair) throws -> Data {
    if let encodeUsingThrowableError {
      throw encodeUsingThrowableError
    }
    if let expKeyPair = expectedKeyPair, expKeyPair != keyPair {
      throw JWSEncoderMockError.unexpectedKeyPair(input: keyPair, expected: expKeyPair)
    }
    guard let data = encodeUsingReturnValue else { throw JWSEncoderMockError.noReturnValue }
    return data
  }
}

// swiftlint: enable force_unwrapping force_cast
#endif
