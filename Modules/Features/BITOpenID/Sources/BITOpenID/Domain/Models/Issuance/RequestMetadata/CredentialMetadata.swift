import BITCore
import BITJWT
import BITVault
import Foundation
import OSLog

// MARK: - CredentialMetadata

public struct CredentialMetadata: Decodable {

  // MARK: Lifecycle

  init(
    credentialIssuer: String,
    credentialEndpoint: String,
    credentialConfigurationsSupported: [String: any AnyCredentialConfigurationSupported],
    display: [CredentialMetadataDisplay]?,
    deferredCredentialEndpoint: URL? = nil)
  {
    self.credentialIssuer = credentialIssuer
    self.credentialEndpoint = credentialEndpoint
    self.credentialConfigurationsSupported = credentialConfigurationsSupported
    self.display = display
    preferredDisplay = display?.findDisplayWithFallback()
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let credentialIssuer = try container.decode(String.self, forKey: .credentialIssuer)
    let credentialEndpoint = try container.decode(String.self, forKey: .credentialEndpoint)
    let display = try container.decode([CredentialMetadataDisplay].self, forKey: .display)
    let deferredCredentialEndpoint = try container.decodeIfPresent(URL.self, forKey: .deferredCredentialEndpoint)

    let decodedAnyCredentialConfigurationsSupported = try container.decode([String: CredentialConfigurationSupportedWrapper].self, forKey: .credentialConfigurationsSupported)
    let anyCredentialConfigurationsSupported = decodedAnyCredentialConfigurationsSupported.compactMapValues { $0.anyCredentialConfigurationSupported }

    self.init(credentialIssuer: credentialIssuer, credentialEndpoint: credentialEndpoint, credentialConfigurationsSupported: anyCredentialConfigurationsSupported, display: display, deferredCredentialEndpoint: deferredCredentialEndpoint)
  }

  // MARK: Public

  public let credentialEndpoint: String
  public let credentialIssuer: String
  public let display: [CredentialMetadataDisplay]?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case credentialIssuer = "credential_issuer"
    case credentialEndpoint = "credential_endpoint"
    case credentialConfigurationsSupported = "credential_configurations_supported"
    case display
    case preferredDisplay
    case deferredCredentialEndpoint = "deferred_credential_endpoint"
  }

  let credentialConfigurationsSupported: [String: any AnyCredentialConfigurationSupported]
  let preferredDisplay: CredentialMetadataDisplay?
  let deferredCredentialEndpoint: URL?

}

extension CredentialMetadata {

  // MARK: Public

  public enum ProofType: ProofTypeProcotol, Equatable {
    /// Supported types for proof signing as defined in the specification.
    /// - Specification: [OpenID for Verifiable Credential Issuance 1.0](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0-13.html#section-11.2.3-2.11.2.5.2.1)
    case jwt(JwtProofType)

    // MARK: Public

    public var algorithms: [String] {
      switch self {
      case .jwt(let type): type.supportedAlgorithms.map(\.rawValue)
      }
    }

    public var keyAttestationRequirements: KeyAttestationRequirements? {
      switch self {
      case .jwt(let type): type.keyAttestationRequirements
      }
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case jwt
    }

  }

  public protocol ProofTypeProcotol: Decodable {
    var algorithms: [String] { get }
  }

  public struct JwtProofType: Decodable, Equatable {

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let decodedAlgorithms = try container.decode([String].self, forKey: .supportedAlgorithms)
      let algorithms = decodedAlgorithms.compactMap { JWTAlgorithm(rawValue: $0) }

      guard !algorithms.isEmpty else {
        throw AnyCredentialConfigurationSupportedError.invalidProofType
      }
      supportedAlgorithms = algorithms
      keyAttestationRequirements = try container.decodeIfPresent(KeyAttestationRequirements.self, forKey: .keyAttestationRequirements)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case supportedAlgorithms = "proof_signing_alg_values_supported"
      case keyAttestationRequirements = "key_attestations_required"
    }

    let supportedAlgorithms: [JWTAlgorithm]
    let keyAttestationRequirements: KeyAttestationRequirements?
  }

  public struct KeyAttestationRequirements: Decodable, Equatable {
    enum CodingKeys: String, CodingKey {
      case keyStorage = "key_storage"
    }

    public let keyStorage: [KeyStorageSecurityLevel]
  }

  public enum CryptographicBindingMethod: String {
    case didJwk = "did:jwk"
    case jwk
  }

  public struct CredentialSupportedDisplay: Decodable, Equatable {

    // MARK: Lifecycle

    init(
      name: String,
      locale: String? = nil,
      logo: CredentialSupportedDisplayLogo? = nil,
      summary: String? = nil,
      backgroundColor: String? = nil)
    {
      self.name = name
      self.locale = locale
      self.logo = logo
      self.summary = summary
      self.backgroundColor = backgroundColor
    }

    // MARK: Public

    public let name: String
    public let locale: String?
    public let logo: CredentialSupportedDisplayLogo?
    public let summary: String?
    public let backgroundColor: String?

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case name, locale, logo
      case summary = "description"
      case backgroundColor = "background_color"
    }

  }

  public struct CredentialSupportedDisplayLogo: Codable, Equatable {

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      altText = try container.decodeIfPresent(String.self, forKey: .altText)
      url = try container.decodeIfPresent(URL.self, forKey: .url)
    }

    // MARK: Public

    public let altText: String?
    public let url: URL?

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case url = "uri"
      case altText = "alt_text"
    }
  }

  // MARK: Internal

  enum CredentialSupportedDisplayLogoError: Error {
    case invalidScheme
  }
}

// MARK: CredentialMetadata.DecodedClaimArray

extension CredentialMetadata {
  struct DecodedClaimArray: Decodable {

    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: DynamicCodingKey.self)
      var tempArray = [Claim]()

      for key in container.allKeys {
        guard let key = DynamicCodingKey(stringValue: key.stringValue) else { continue }
        let decodedObject = try container.decode(Claim.self, forKey: key)
        tempArray.append(decodedObject)
      }

      claims = tempArray
    }

    // MARK: Internal

    var claims: [Claim]
  }
}

// MARK: CredentialMetadata.Claim

extension CredentialMetadata {
  public struct Claim: Decodable, Equatable {

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      mandatory = try container.decodeIfPresent(Bool.self, forKey: .mandatory)
      valueType = try container.decodeIfPresent(ValueType.self, forKey: .valueType)
      display = try container.decodeIfPresent([ClaimDisplay].self, forKey: .display)
      order = try container.decodeIfPresent(Int.self, forKey: .order)
      guard let key = container.codingPath.last?.stringValue else {
        throw NSError(domain: "No key found", code: 1)
      }
      self.key = key
    }

    init(from claim: Claim, order: Int?) {
      key = claim.key
      mandatory = claim.mandatory
      valueType = claim.valueType
      display = claim.display
      self.order = order
    }

    // MARK: Public

    public let mandatory: Bool?
    public let key: String
    public let valueType: ValueType?
    public let display: [ClaimDisplay]?
    public let order: Int?

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case mandatory
      case valueType = "value_type"
      case display
      case order
    }

  }
}

// MARK: CredentialMetadata.ClaimDisplay

extension CredentialMetadata {
  public struct ClaimDisplay: Decodable, Equatable {
    public let locale: String
    public let name: String

    public init(locale: String, name: String) {
      self.locale = locale
      self.name = name
    }
  }
}

// MARK: CredentialMetadata.CredentialMetadataDisplay

extension CredentialMetadata {

  public struct CredentialMetadataDisplay: Decodable, Equatable, DisplayLocalizable {
    public let name: String
    public let locale: String?
    public let logo: CredentialSupportedDisplayLogo?
  }
}
