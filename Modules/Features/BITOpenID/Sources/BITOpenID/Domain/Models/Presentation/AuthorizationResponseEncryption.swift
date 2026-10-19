import BITCore
import BITCrypto
import Foundation

public struct AuthorizationResponseEncryption: Equatable, Changeable, Sendable {

  let jwk: JWK
  let algorithm: EncryptionAlgorithm
}
