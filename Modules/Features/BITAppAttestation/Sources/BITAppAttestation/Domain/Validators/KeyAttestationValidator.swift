import BITCrypto
import BITJWT
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - KeyAttestationValidatorProtocol

@Spyable
protocol KeyAttestationValidatorProtocol {
  func validate(keyPair: VaultKeyPair, with keyAttestation: KeyAttestation) async -> Bool
}

// MARK: - KeyAttestationValidator

struct KeyAttestationValidator: KeyAttestationValidatorProtocol {

  // MARK: Internal

  func validate(keyPair: VaultKeyPair, with keyAttestation: KeyAttestation) async -> Bool {
    do {
      guard
        keyAttestation.header.algorithm == .ES256,
        let kid = keyAttestation.header.keyIdentifier,
        hasValidKid(kid)
      else {
        throw KeyAttestationValidatorError.invalidHeader
      }

      guard
        keyAttestation.payload.expiredAt != nil,
        let issuer = keyAttestation.payload.issuer,
        attestationServiceTrustedDids.contains(issuer),
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

  private static let kidSeparator: Character = "#"

  @Injected(\.attestationServiceTrustedDids) private var attestationServiceTrustedDids: [String]
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.supportedKeyStorageSecurityLevel) private var supportedKeyStorageSecurityLevel: [KeyStorageSecurityLevel]

  private var now: Date {
    Date()
  }

  private func hasValidKid(_ kid: String) -> Bool {
    guard let did = kid.split(separator: Self.kidSeparator).first, !did.isEmpty else {
      return false
    }

    return attestationServiceTrustedDids.contains(String(did))
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
