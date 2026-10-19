import Foundation
import JWSETKit
import Security

extension AnyJSONWebKey {
  func toPublicSecKey() throws -> SecKey {
    // swiftformat:disable:next redundantSelf
    guard let x = self.xCoordinate, let y = self.yCoordinate else {
      throw JWK.JWKError.invalidSecKey
    }

    // A public EC key in bytes is: 0x04 followed by the X and Y coordinates.
    let uncompressedPoint = Data([0x04]) + x + y
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
    ]

    var error: Unmanaged<CFError>?
    guard let key = SecKeyCreateWithData(uncompressedPoint as CFData, attributes as CFDictionary, &error) else {
      throw JWK.JWKError.invalidSecKey
    }
    return key
  }
}
