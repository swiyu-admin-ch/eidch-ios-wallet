#if DEBUG
import Foundation
@testable import BITVault

// MARK: - JWSEncoderMockError

// swiftlint: disable force_unwrapping force_cast

enum JWSEncoderMockError: Error {
  case noReturnValue
}

// MARK: - JWSEncoderMock

class JWSEncoderMock<U: Codable & Equatable>: JWSEncoderProtocol {

  var encodeUsingReturnValue: Data?
  var receivedKeyPair: VaultKeyPair?
  var receivedValue: U?
  var receivedAdditionalHeaderParameters: [String: Any] = [:]
  var encodeUsingThrowableError: Error?
  var encodeReturnValue: JWS<U>?

  func encode(_ value: some JWTPayload & Encodable, using keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> Data {
    if let encodeUsingThrowableError {
      throw encodeUsingThrowableError
    }
    receivedKeyPair = keyPair
    receivedValue = value as? U
    receivedAdditionalHeaderParameters = additionalHeaderParameters
    guard let data = encodeUsingReturnValue else { throw JWSEncoderMockError.noReturnValue }
    return data
  }

  func encode<T>(_ value: T, keyPair: VaultKeyPair) throws -> JWS<T> where T: JWTPayload, T: Decodable, T: Encodable, T: Equatable {
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
