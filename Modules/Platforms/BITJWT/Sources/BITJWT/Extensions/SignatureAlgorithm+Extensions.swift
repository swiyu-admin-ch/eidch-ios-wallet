import Foundation
import JWSETKit

extension JSONWebSignatureAlgorithm {

  init(from jwtAlgorithm: JWTAlgorithm) {
    switch jwtAlgorithm {
    case .ES256:
      self = .ecdsaSignatureP256SHA256
    case .ES384:
      self = .ecdsaSignatureP384SHA384
    case .ES512:
      self = .ecdsaSignatureP521SHA512
    case .Ed25519:
      self = .eddsa25519Signature
    }
  }

}
