import BITCore
import BITCrypto
import Foundation

public struct AuthorizationResponseEncryption: Equatable, Changeable {

  let jwk: JWK
  let algorithm: EncryptionAlgorithm
}
