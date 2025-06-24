import BITAppAuth
import BITCrypto
import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - KeyAttestationValidatorProtocol

@Spyable
protocol KeyAttestationValidatorProtocol {
  func validate(_ keyAttestation: KeyAttestation) async -> Bool
}

// MARK: - KeyAttestationValidator

struct KeyAttestationValidator: KeyAttestationValidatorProtocol {

  // MARK: Internal

  func validate(_ keyAttestation: KeyAttestation) async -> Bool {
    do {
      guard
        keyAttestation.header.algorithm == .ES256,
        let kid = keyAttestation.header.keyIdentifier,
        hasValidKid(kid)
      else {
        throw KeyAttestationValidatorError.invalidHeader
      }

      guard
        attestationServiceTrustedDids.contains(keyAttestation.payload.issuer),
        keyAttestation.payload.issuedAt <= now,
        keyAttestation.payload.expiredAt >= now,
        Self.supportedKeyStorages.contains(keyAttestation.payload.keyStorage),
        try hasValidAttestedKey(keyAttestation.payload.attestedKeys)
      else {
        throw ClientAttestationValidatorError.invalidPayload
      }

      return try await jwsSignatureValidator.validate(keyAttestation, did: keyAttestation.payload.issuer)
    } catch {
      return false
    }
  }

  // MARK: Private

  private static let kidSeparator: Character = "#"
  private static let supportedKeyStorages: [KeyAttestationKeyStorage] = [.iso18045EnhancedBasic, .iso18045High]

  @Injected(\.attestationServiceTrustedDids) private var attestationServiceTrustedDids: [String]
  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol

  private var now: Date {
    Date()
  }

  private func hasValidKid(_ kid: String) -> Bool {
    guard let did = kid.split(separator: Self.kidSeparator).first, !did.isEmpty else {
      return false
    }

    return attestationServiceTrustedDids.contains(String(did))
  }

  private func hasValidAttestedKey(_ jwks: [JWK]) throws -> Bool {
    let privateKey = try appAttestationKeyRepository.getAttestionKey(for: .keyAttestation)
    let keyPair = KeyPair(privateKey: privateKey)

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
