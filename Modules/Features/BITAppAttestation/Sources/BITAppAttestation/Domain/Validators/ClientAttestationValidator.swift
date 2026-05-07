import BITAppInfo
import BITCrypto
import BITJsonCanonicalizer
import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - ClientAttestationValidatorProtocol

@Spyable
protocol ClientAttestationValidatorProtocol {
  func callAsFunction(_ clientAttestation: ClientAttestation) async -> Bool
}

// MARK: - ClientAttestationValidator

struct ClientAttestationValidator: ClientAttestationValidatorProtocol {

  // MARK: Internal

  func callAsFunction(_ clientAttestation: ClientAttestation) async -> Bool {
    do {
      guard
        clientAttestationSupportedAlgorithms.contains(clientAttestation.header.algorithm),
        let kid = clientAttestation.header.keyIdentifier,
        hasValidKid(kid)
      else {
        throw ClientAttestationValidatorError.invalidHeader
      }

      guard
        let issuer = clientAttestation.payload.issuer,
        clientAttestation.payload.expiredAt != nil,
        clientAttestation.payload.activatedAt != nil,
        attestationServiceTrustedDids.contains(issuer),
        hasValidSubject(clientAttestation),
        hasValidWalletName(clientAttestation),
        hasValidBindingKey(clientAttestation.payload.bindingKey.jwk)
      else {
        throw ClientAttestationValidatorError.invalidPayload
      }

      try await jwsValidator.validate(clientAttestation)
      return true
    } catch {
      return false
    }
  }

  // MARK: Private

  private static let didJwk = "did:jwk:"
  private static let kidSeparator: Character = "#"

  private let clientAttestationSupportedAlgorithms: [JWTAlgorithm] = [.ES256]

  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol
  @Injected(\.attestationServiceTrustedDids) private var attestationServiceTrustedDids: [String]
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol
  @Injected(\.appIdentifierRepository) private var appIdentifierRepository: AppIdentifierRepositoryProtocol

  private var now: Date {
    Date()
  }

  private func hasValidBindingKey(_ jwk: JWK) -> Bool {
    do {
      let keyPair = try appAttestationKeyRepository.get(for: .client)

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

  private func hasValidWalletName(_ clientAttestation: ClientAttestation) -> Bool {
    guard let appIdentifier = try? appIdentifierRepository.get() else {
      return false
    }

    return clientAttestation.payload.walletName == appIdentifier
  }
}

// MARK: - ClientAttestationValidatorError

enum ClientAttestationValidatorError: Error {
  case invalidHeader
  case invalidPayload
}
