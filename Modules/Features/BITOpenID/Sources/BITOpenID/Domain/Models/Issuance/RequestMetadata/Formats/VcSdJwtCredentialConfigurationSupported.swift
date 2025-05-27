import BITAnyCredentialFormat
import BITJWT
import Foundation

// MARK: - CredentialMetadata.VcSdJwtCredentialConfigurationSupported

extension CredentialMetadata {

  /// `vc+sd-jwt` implementation of the `credential_configurations_supported`
  /// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0-ID1.html#name-credential-issuer-metadata-6
  public struct VcSdJwtCredentialConfigurationSupported: AnyCredentialConfigurationSupported, Decodable, Equatable {

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let format = try container.decode(String.self, forKey: .format)
      guard format == CredentialFormat.vcSdJwt.rawValue else {
        throw VcSdJwtCredentialConfigurationSupportedError.invalidVcSdJwtFormat
      }
      self.format = format

      vct = try container.decode(String.self, forKey: .vct)
      scope = try container.decodeIfPresent(String.self, forKey: .scope)

      let cryptographicBindingMethods = try container.decodeIfPresent([String].self, forKey: .cryptographicBindingMethodsSupported)
      cryptographicBindingMethodsSupported = cryptographicBindingMethods?.compactMap { CryptographicBindingMethod(rawValue: $0) }
      if cryptographicBindingMethods != nil, cryptographicBindingMethodsSupported?.isEmpty == true {
        throw AnyCredentialConfigurationSupportedError.invalidCryptographicBindingMethod
      }
      credentialSigningAlgValuesSupported = try container.decodeIfPresent([String].self, forKey: .credentialSigningAlgValuesSupported)

      var proofTypes = [ProofType]()
      if let proofTypesContainer = try? container.nestedContainer(keyedBy: ProofType.CodingKeys.self, forKey: .proofTypesSupported) {
        if let jwt = try proofTypesContainer.decodeIfPresent(JwtProofType.self, forKey: .jwt) {
          proofTypes.append(.jwt(jwt))
        }
        if proofTypes.isEmpty { throw VcSdJwtCredentialConfigurationSupportedError.invalidProofType }
      }
      proofTypesSupported = proofTypes

      display = try container.decodeIfPresent([CredentialSupportedDisplay].self, forKey: .display)
      orderClaims = try container.decodeIfPresent([String].self, forKey: .orderClaims)

      let metadataClaims = try container.decode(CredentialMetadata.DecodedClaimArray.self, forKey: .claims)

      claims = []

      for claim in metadataClaims.claims {
        let index = orderClaims?.firstIndex(where: { $0 == claim.key })
        claims.append(CredentialMetadata.Claim(from: claim, order: index))
      }
    }

    // MARK: Public

    public let format: String
    public let scope: String?
    public let cryptographicBindingMethodsSupported: [CryptographicBindingMethod]?
    public let credentialSigningAlgValuesSupported: [String]?

    public let vct: String

    public let display: [CredentialSupportedDisplay]?
    public let proofTypesSupported: [ProofType]
    public let orderClaims: [String]?

    public var claims: [CredentialMetadata.Claim]

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case vct
      case format
      case scope
      case cryptographicBindingMethodsSupported = "cryptographic_binding_methods_supported"
      case credentialSigningAlgValuesSupported = "credential_signing_alg_values_supported"
      case proofTypesSupported = "proof_types_supported"
      case claims
      case display
      case orderClaims = "order"
    }

    enum VcSdJwtCredentialConfigurationSupportedError: Error {
      case invalidVcSdJwtFormat
      case invalidProofType
    }
  }
}
