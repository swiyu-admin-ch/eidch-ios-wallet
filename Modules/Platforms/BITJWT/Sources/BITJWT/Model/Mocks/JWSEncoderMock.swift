#if DEBUG
import Foundation
@testable import BITVault

// MARK: - JWSEncoderMockError

// swiftlint: disable force_unwrapping force_cast

enum JWSEncoderMockError: Error {
  case noReturnValue
}

// MARK: - JWSEncoderMock

class JWSEncoderMock<U: JWT>: JWSEncoderProtocol {

  var encodeUsingReturnValue: Data?
  var receivedKeyPair: VaultKeyPair?
  var receivedValue: U?
  var receivedAdditionalHeaderParameters = [String: Any]()
  var encodeUsingThrowableError: Error?
  var encodeReturnValue: JWS<U>?

  func encode(_ value: some JWT, using keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> Data {
    if let encodeUsingThrowableError {
      throw encodeUsingThrowableError
    }
    receivedKeyPair = keyPair
    receivedValue = value as? U
    receivedAdditionalHeaderParameters = additionalHeaderParameters
    guard let data = encodeUsingReturnValue else { throw JWSEncoderMockError.noReturnValue }
    return data
  }

  func encode<T: JWT>(_ value: T, keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> JWS<T> {
    if let encodeUsingThrowableError {
      throw encodeUsingThrowableError
    }
    receivedKeyPair = keyPair
    receivedValue = value as? U
    receivedAdditionalHeaderParameters = additionalHeaderParameters
    guard let jws = encodeReturnValue else { throw JWSEncoderMockError.noReturnValue }

    return jws as! JWS<T>
  }
}

// swiftlint: enable force_unwrapping force_cast
#endif
