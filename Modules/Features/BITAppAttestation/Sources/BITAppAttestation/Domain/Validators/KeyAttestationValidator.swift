import BITCrypto
import BITJWT
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - KeyAttestationValidatorProtocol

@Spyable
public protocol KeyAttestationValidatorProtocol {
  func callAsFunction(keyPair: VaultKeyPair, with keyAttestation: KeyAttestation) async -> Bool
}

// MARK: - KeyAttestationValidator

struct KeyAttestationValidator: KeyAttestationValidatorProtocol {

  // MARK: Internal

  func callAsFunction(keyPair: VaultKeyPair, with keyAttestation: KeyAttestation) async -> Bool {
    do {
      guard
        keyAttestation.header.algorithm == .ES256,
        let did = try? didResolverHelper.getDid(from: keyAttestation.header.keyIdentifier),
        attestationServiceTrustedDids.contains(did)
      else {
        throw KeyAttestationValidatorError.invalidHeader
      }

      guard
        keyAttestation.payload.expiredAt != nil,
        supportedKeyStorageSecurityLevel.contains(keyAttestation.payload.keyStorage),
        try hasValidAttestedKey(keyPair, keyAttestation.payload.attestedKeys)
      else {
        throw ClientAttestationValidatorError.invalidPayload
      }

      try await jwsValidator.validate(keyAttestation)
      return true
    } catch {
      return false
    }
  }

  // MARK: Private

  @Injected(\.attestationServiceTrustedDids) private var attestationServiceTrustedDids: [String]
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol
  @Injected(\.supportedKeyStorageSecurityLevel) private var supportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel]

  private var now: Date {
    Date()
  }

  private func hasValidAttestedKey(_ keyPair: VaultKeyPair, _ jwks: [JWK]) throws -> Bool {
    guard let publicKey = keyPair.publicKey, let jwk = try? JWK(from: publicKey) else {
      throw KeyAttestationValidatorError.invalidPublicKey
    }

    return jwks.contains(jwk)
  }

}

// MARK: - KeyAttestationValidatorError

enum KeyAttestationValidatorError: Error {
  case invalidHeader
  case invalidPayload
  case invalidPublicKey
}
