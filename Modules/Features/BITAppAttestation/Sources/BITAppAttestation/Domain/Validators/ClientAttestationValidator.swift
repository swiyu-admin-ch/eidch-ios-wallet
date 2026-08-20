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
        supportedSignatureValidationAlgorithms.contains(clientAttestation.header.algorithm),
        let did = try? didResolverHelper.getDid(from: clientAttestation.header.keyIdentifier),
        attestationServiceTrustedDids.contains(did)
      else {
        throw ClientAttestationValidatorError.invalidHeader
      }

      guard
        clientAttestation.payload.expiredAt != nil,
        clientAttestation.payload.activatedAt != nil,
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

  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol
  @Injected(\.attestationServiceTrustedDids) private var attestationServiceTrustedDids: [String]
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol
  @Injected(\.supportedSignatureValidationAlgorithms) private var supportedSignatureValidationAlgorithms: [JWTAlgorithm]
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
