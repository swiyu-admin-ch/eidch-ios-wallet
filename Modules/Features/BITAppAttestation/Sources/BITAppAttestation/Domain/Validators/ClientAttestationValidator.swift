import BITAppAuth
import BITCrypto
import BITJsonCanonicalizer
import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - ClientAttestationValidatorProtocol

@Spyable
protocol ClientAttestationValidatorProtocol {
  func validate(_ clientAttestation: ClientAttestation) async -> Bool
}

// MARK: - ClientAttestationValidator

struct ClientAttestationValidator: ClientAttestationValidatorProtocol {

  // MARK: Internal

  func validate(_ clientAttestation: ClientAttestation) async -> Bool {
    do {
      guard
        clientAttestationSupportedAlgorithms.contains(clientAttestation.header.algorithm),
        let kid = clientAttestation.header.keyIdentifier,
        hasValidKid(kid)
      else {
        throw ClientAttestationValidatorError.invalidHeader
      }

      guard
        attestationServiceTrustedDids.contains(clientAttestation.payload.issuer),
        hasValidSubject(clientAttestation),
        clientAttestation.payload.walletName == Self.supportedWalletName,
        clientAttestation.payload.activatedAt <= now,
        hasValidBindingKey(clientAttestation.payload.bindingKey.jwk),
        clientAttestation.payload.expiredAt >= now
      else {
        throw ClientAttestationValidatorError.invalidPayload
      }

      return try await jwsSignatureValidator.validate(clientAttestation, did: clientAttestation.payload.issuer)
    } catch {
      return false
    }
  }

  // MARK: Private

  private static let didJwk = "did:jwk:"
  private static let kidSeparator: Character = "#"
  private static let supportedWalletName = "swiyu"

  private let clientAttestationSupportedAlgorithms: [JWTAlgorithm] = [.ES256]

  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol
  @Injected(\.attestationServiceTrustedDids) private var attestationServiceTrustedDids: [String]
  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol

  private var now: Date {
    Date()
  }

  private func hasValidBindingKey(_ jwk: JWK) -> Bool {
    do {
      let bindingKey = try appAttestationKeyRepository.getAttestionKey(for: .clientAttestation)
      let keyPair = KeyPair(privateKey: bindingKey)

      guard
        let publicKey = keyPair.publicKey,
        let bindingKeyJWK = try? JWK(from: publicKey)
      else {
        return false
      }

      return bindingKeyJWK == jwk
    } catch {
      return false
    }
  }

  private func hasValidKid(_ kid: String) -> Bool {
    let components = kid.split(separator: Self.kidSeparator)

    guard let did = components.first, !did.isEmpty else {
      return false
    }

    return attestationServiceTrustedDids.contains(String(did))
  }

  private func hasValidSubject(_ clientAttestation: ClientAttestation) -> Bool {
    let jwk = clientAttestation.payload.bindingKey.jwk
    let subject = clientAttestation.payload.subject

    guard
      let jwkData = try? JSONEncoder().encode(jwk),
      let jwkBase64 = try? jsonCanonicalizer.canonicalize(data: jwkData).base64URLEncodedString()
    else {
      return false
    }

    let didJwk = Self.didJwk + jwkBase64

    return subject == didJwk
  }
}

// MARK: - ClientAttestationValidatorError

enum ClientAttestationValidatorError: Error {
  case invalidHeader
  case invalidPayload
}
