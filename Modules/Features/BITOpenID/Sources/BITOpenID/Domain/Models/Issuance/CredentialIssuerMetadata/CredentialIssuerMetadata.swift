import BITClaimsPathPointer
import BITCore
import BITCrypto
import BITJWT
import BITVault
import Foundation
import OSLog

// MARK: - CredentialIssuerMetadataError

enum CredentialIssuerMetadataError: Error {
  case invalidBatchSize
}

// MARK: - CredentialIssuerMetadata

public struct CredentialIssuerMetadata: Decodable, Changeable {

  // MARK: Lifecycle

  init(
    credentialIssuer: URL,
    identityTrustStatement: IdentityTrustStatement? = nil,
    credentialEndpoint: String,
    credentialConfigurationsSupported: [String: any AnyCredentialConfigurationSupported],
    display: [Display]?,
    batchCredentialIssuance: BatchCredentialIssuance? = nil,
    credentialRequestEncryption: CredentialRequestEncryption,
    credentialResponseEncryption: CredentialResponseEncryption,
    nonceEndpoint: URL,
    deferredCredentialEndpoint: URL? = nil)
  {
    self.credentialIssuer = credentialIssuer
    self.identityTrustStatement = identityTrustStatement
    self.credentialEndpoint = credentialEndpoint
    self.credentialConfigurationsSupported = credentialConfigurationsSupported
    self.display = display
    preferredDisplay = display?.findDisplayWithFallback()
    self.batchCredentialIssuance = batchCredentialIssuance
    self.credentialRequestEncryption = credentialRequestEncryption
    self.credentialResponseEncryption = credentialResponseEncryption
    self.nonceEndpoint = nonceEndpoint
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let credentialIssuer = try container.decode(URL.self, forKey: .credentialIssuer)
    let credentialEndpoint = try container.decode(String.self, forKey: .credentialEndpoint)
    let display = try container.decodeIfPresent([Display].self, forKey: .display)
    let nonceEndpoint = try container.decode(URL.self, forKey: .nonceEndpoint)
    guard nonceEndpoint.isValidHttpUrl else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.nonceEndpoint], debugDescription: "Nonce endpoint not a valid HTTP URL"))
    }
    let deferredCredentialEndpoint = try container.decodeIfPresent(URL.self, forKey: .deferredCredentialEndpoint)
    let batchCredentialIssuance = try container.decodeIfPresent(BatchCredentialIssuance.self, forKey: .batchCredentialIssuance)
    let credentialRequestEncryption = try container.decode(CredentialRequestEncryption.self, forKey: .credentialRequestEncryption)
    let credentialResponseEncryption = try container.decode(CredentialResponseEncryption.self, forKey: .credentialResponseEncryption)
    let identityTrustStatement: IdentityTrustStatement? = if let idTSString = try container.decodeIfPresent(String.self, forKey: .credentialIssuerIdTS) {
      try JWSDecoder().decode(IdentityTrustStatementJWT.self, from: Data(idTSString.utf8))
    } else {
      nil
    }

    let decodedAnyCredentialConfigurationsSupported = try container.decode([String: CredentialConfigurationSupportedWrapper].self, forKey: .credentialConfigurationsSupported)
    let anyCredentialConfigurationsSupported = decodedAnyCredentialConfigurationsSupported.compactMapValues { $0.anyCredentialConfigurationSupported }

    self.init(
      credentialIssuer: credentialIssuer,
      identityTrustStatement: identityTrustStatement,
      credentialEndpoint: credentialEndpoint,
      credentialConfigurationsSupported: anyCredentialConfigurationsSupported,
      display: display,
      batchCredentialIssuance: batchCredentialIssuance,
      credentialRequestEncryption: credentialRequestEncryption,
      credentialResponseEncryption: credentialResponseEncryption,
      nonceEndpoint: nonceEndpoint,
      deferredCredentialEndpoint: deferredCredentialEndpoint)
  }

  // MARK: Public

  public let credentialEndpoint: String
  public var credentialIssuer: URL
  public var identityTrustStatement: IdentityTrustStatement?
  public var display: [Display]?
  public var deferredCredentialEndpoint: URL?
  public var batchCredentialIssuance: BatchCredentialIssuance?
  public var nonceEndpoint: URL

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case credentialIssuer = "credential_issuer"
    case credentialIssuerIdTS = "credential_issuer_identity_trust_statement"
    case credentialEndpoint = "credential_endpoint"
    case credentialConfigurationsSupported = "credential_configurations_supported"
    case credentialRequestEncryption = "credential_request_encryption"
    case credentialResponseEncryption = "credential_response_encryption"
    case display
    case preferredDisplay
    case nonceEndpoint = "nonce_endpoint"
    case deferredCredentialEndpoint = "deferred_credential_endpoint"
    case batchCredentialIssuance = "batch_credential_issuance"
  }

  var credentialConfigurationsSupported: [String: any AnyCredentialConfigurationSupported]
  let preferredDisplay: Display?
  var credentialRequestEncryption: CredentialRequestEncryption
  var credentialResponseEncryption: CredentialResponseEncryption
}

// MARK: CredentialIssuerMetadata.BatchCredentialIssuance

extension CredentialIssuerMetadata {
  public struct BatchCredentialIssuance: Decodable, Equatable {

    init(batchSize: Int) {
      self.batchSize = batchSize
    }

    public let batchSize: Int

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      batchSize = try container.decode(Int.self, forKey: CodingKeys.batchSize)
      guard batchSize >= 10 else { throw CredentialIssuerMetadataError.invalidBatchSize }
    }

    enum CodingKeys: String, CodingKey {
      case batchSize = "batch_size"
    }
  }
}

extension CredentialIssuerMetadata {

  // MARK: CredentialRequestEncryption

  public struct CredentialRequestEncryption: Decodable, Equatable {
    public let jwks: JWKs
    public let supportedEncryptionAlgorithms: [EncryptionAlgorithm]
    public let supportedZipValues: [CompressionAlgorithm]?
    public let encryptionRequired: Bool

    enum CodingKeys: String, CodingKey {
      case jwks
      case supportedEncryptionAlgorithms = "enc_values_supported"
      case supportedZipValues = "zip_values_supported"
      case encryptionRequired = "encryption_required"
    }

    public struct JWKs: Decodable, Equatable {
      let keys: [JWK]
    }
  }

  // MARK: CredentialRequestEncryption

  public struct CredentialResponseEncryption: Decodable, Equatable {
    public let supportedAlgorithmValues: [KeyManagementAlgorithm]
    public let supportedEncryptionAlgorithms: [EncryptionAlgorithm]
    public let supportedZipValues: [CompressionAlgorithm]?
    public let encryptionRequired: Bool

    enum CodingKeys: String, CodingKey {
      case encryptionRequired = "encryption_required"
      case supportedAlgorithmValues = "alg_values_supported"
      case supportedEncryptionAlgorithms = "enc_values_supported"
      case supportedZipValues = "zip_values_supported"
    }
  }
}

extension CredentialIssuerMetadata {

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

    init(supportedAlgorithms: [JWTAlgorithm], keyAttestationRequirements: KeyAttestationRequirements?) {
      self.supportedAlgorithms = supportedAlgorithms
      self.keyAttestationRequirements = keyAttestationRequirements
    }

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
    case jwk
  }
}

// MARK: CredentialIssuerMetadata.CredentialMetadata

extension CredentialIssuerMetadata {
  public struct CredentialMetadata: Codable, Equatable {
    public struct Claim: Codable, Equatable {

      // MARK: Lifecycle

      public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CredentialIssuerMetadata.CredentialMetadata.Claim.CodingKeys.self)
        #warning("TODO: remove stringPath when Raeda doesn't need it anymore")
        if let stringPath = try? container.decode(String.self, forKey: CredentialIssuerMetadata.CredentialMetadata.Claim.CodingKeys.path) {
          path = [.string(stringPath)]
        } else {
          let array = try container.decode(ClaimsPathPointer.self, forKey: CredentialIssuerMetadata.CredentialMetadata.Claim.CodingKeys.path)
          path = array
        }
        mandatory = try container.decodeIfPresent(Bool.self, forKey: CredentialIssuerMetadata.CredentialMetadata.Claim.CodingKeys.mandatory)
        display = try container.decodeIfPresent([CredentialIssuerMetadata.CredentialMetadata.Claim.Display].self, forKey: CredentialIssuerMetadata.CredentialMetadata.Claim.CodingKeys.display)
      }

      // MARK: Public

      public struct Display: Codable, Equatable, DisplayLocalizable {

        // MARK: Lifecycle

        init(
          name: String? = nil,
          locale: String? = nil)
        {
          self.name = name
          self.locale = locale
        }

        // MARK: Public

        public let name: String?
        public let locale: String?
      }

      public let path: ClaimsPathPointer
      public let mandatory: Bool?
      public let display: [Display]?
    }

    public struct Display: Codable, Equatable, DisplayLocalizable {

      // MARK: Lifecycle

      init(
        name: String? = nil,
        locale: String? = nil,
        logo: Logo? = nil,
        description: String? = nil,
        backgroundColor: String? = nil,
        backgroundImage: Logo? = nil)
      {
        self.name = name
        self.locale = locale
        self.logo = logo
        self.description = description
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
      }

      // MARK: Public

      public let name: String?
      public let locale: String?
      public let logo: Logo?
      public let description: String?
      public let backgroundColor: String?
      public let backgroundImage: Logo?

      // MARK: Internal

      enum CodingKeys: String, CodingKey {
        case name, locale, logo
        case description
        case backgroundColor = "background_color"
        case backgroundImage = "background_image"
      }
    }

    public let display: [Display]?
    public let claims: [Claim]?
  }
}

// MARK: CredentialIssuerMetadata.Display

extension CredentialIssuerMetadata {
  public struct Display: Codable, Equatable, DisplayLocalizable {

    // MARK: Lifecycle

    init(
      name: String? = nil,
      locale: String? = nil,
      logo: Logo? = nil)
    {
      self.name = name
      self.locale = locale
      self.logo = logo
    }

    // MARK: Public

    public let name: String?
    public let locale: String?
    public let logo: Logo?
  }
}

// MARK: CredentialIssuerMetadata.Logo

extension CredentialIssuerMetadata {
  public struct Logo: Codable, Equatable {

    // MARK: Lifecycle

    init(
      altText: String? = nil,
      url: URL? = nil)
    {
      self.altText = altText
      self.url = url
    }

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
}

// MARK: Equatable

extension CredentialIssuerMetadata: Equatable {

  // MARK: Public

  public static func == (lhs: CredentialIssuerMetadata, rhs: CredentialIssuerMetadata) -> Bool {
    lhs.credentialEndpoint == rhs.credentialEndpoint
      && lhs.credentialIssuer == rhs.credentialIssuer
      && areCredentialConfigurationsSupportedEqual(lhs.credentialConfigurationsSupported, rhs.credentialConfigurationsSupported)
      && lhs.display == rhs.display
      && lhs.preferredDisplay == rhs.preferredDisplay
      && lhs.deferredCredentialEndpoint == rhs.deferredCredentialEndpoint
  }

  // MARK: Private

  private static func areCredentialConfigurationsSupportedEqual(_ lhs: [String: any AnyCredentialConfigurationSupported], _ rhs: [String: any AnyCredentialConfigurationSupported]) -> Bool {
    guard lhs.count == rhs.count else { return false }

    for (key, lhsConfig) in lhs {
      guard let rhsConfig = rhs[key] else { return false }
      guard areCredentialConfigurationSupportedEqual(lhsConfig, rhsConfig) else { return false }
    }

    return true
  }

  private static func areCredentialConfigurationSupportedEqual(_ lhs: any AnyCredentialConfigurationSupported, _ rhs: any AnyCredentialConfigurationSupported) -> Bool {
    compare(lhs, rhs)
  }

  private static func compare<T: AnyCredentialConfigurationSupported & Equatable>(_ lhs: T, _ rhs: any AnyCredentialConfigurationSupported) -> Bool {
    guard let rhs = rhs as? T else { return false }
    return lhs == rhs
  }
}
