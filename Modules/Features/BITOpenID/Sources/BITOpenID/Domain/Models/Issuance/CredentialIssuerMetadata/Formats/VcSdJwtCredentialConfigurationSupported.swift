import BITAnyCredentialFormat
import BITJWT
import Foundation

// MARK: - CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported

extension CredentialIssuerMetadata {

  /// `vc+sd-jwt` implementation of the `credential_configurations_supported`
  /// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0-ID1.html#name-credential-issuer-metadata-6
  public struct VcSdJwtCredentialConfigurationSupported: AnyCredentialConfigurationSupported, Decodable, Equatable {

    // MARK: Lifecycle

    init(
      format: String,
      scope: String? = nil,
      cryptographicBindingMethodsSupported: [CryptographicBindingMethod]? = nil,
      credentialSigningAlgValuesSupported: [String]? = nil,
      vct: String,
      vctIntegrity: String? = nil,
      vctMetadataUri: String? = nil,
      vctMetadataUriIntegrity: String? = nil,
      proofTypesSupported: [ProofType] = [],
      credentialMetadata: CredentialMetadata? = nil)
    {
      self.format = format
      self.scope = scope
      self.cryptographicBindingMethodsSupported = cryptographicBindingMethodsSupported
      self.credentialSigningAlgValuesSupported = credentialSigningAlgValuesSupported
      self.vct = vct
      self.vctIntegrity = vctIntegrity
      self.vctMetadataUri = vctMetadataUri
      self.vctMetadataUriIntegrity = vctMetadataUriIntegrity
      self.proofTypesSupported = proofTypesSupported
      self.credentialMetadata = credentialMetadata
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let format = try container.decode(String.self, forKey: .format)
      guard format == CredentialFormat.vcSdJwt.rawValue else {
        throw VcSdJwtCredentialConfigurationSupportedError.invalidVcSdJwtFormat
      }
      self.format = format

      vct = try container.decode(String.self, forKey: .vct)
      vctIntegrity = try container.decodeIfPresent(String.self, forKey: .vctIntegrity)
      vctMetadataUri = try container.decodeIfPresent(String.self, forKey: .vctMetadataUri)
      vctMetadataUriIntegrity = try container.decodeIfPresent(String.self, forKey: .vctMetadataUriIntegrity)
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

      credentialMetadata = try container.decodeIfPresent(CredentialMetadata.self, forKey: .credentialMetadata)
    }

    // MARK: Public

    public let format: String
    public let scope: String?
    public let cryptographicBindingMethodsSupported: [CryptographicBindingMethod]?
    public let credentialSigningAlgValuesSupported: [String]?

    public let vct: String
    public let vctIntegrity: String?
    public let vctMetadataUri: String?
    public let vctMetadataUriIntegrity: String?

    public let proofTypesSupported: [ProofType]

    public let credentialMetadata: CredentialMetadata?

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case vct
      case vctIntegrity = "vct#integrity"
      case vctMetadataUri = "vct_metadata_uri"
      case vctMetadataUriIntegrity = "vct_metadata_uri#integrity"
      case format
      case scope
      case cryptographicBindingMethodsSupported = "cryptographic_binding_methods_supported"
      case credentialSigningAlgValuesSupported = "credential_signing_alg_values_supported"
      case proofTypesSupported = "proof_types_supported"
      case credentialMetadata = "credential_metadata"
    }

    enum VcSdJwtCredentialConfigurationSupportedError: Error {
      case invalidVcSdJwtFormat
      case invalidProofType
    }
  }
}
