import BITCore
import BITCrypto
import BITJWT
import BITSwiyuSharedKMP
import Foundation

// MARK: - RequestObjectError

public enum RequestObjectError: Error, Equatable {
  case invalidPayload(_ underlyingError: Error? = nil)
  case invalidQuery
  case missingDcqlQuery
  case duplicateTrustStatement
  case missingVQPS
  case verifiedAndNotVerifiedQueryPresent
  case noQueryFoundOnVQPS

  // MARK: Public

  public static func == (lhs: RequestObjectError, rhs: RequestObjectError) -> Bool {
    switch (lhs, rhs) {
    case (.duplicateTrustStatement, .duplicateTrustStatement),
         (.invalidPayload, .invalidPayload),
         (.invalidQuery, .invalidQuery),
         (.missingDcqlQuery, .missingDcqlQuery),
         (.missingVQPS, .missingVQPS),
         (.noQueryFoundOnVQPS, .noQueryFoundOnVQPS),
         (.verifiedAndNotVerifiedQueryPresent, .verifiedAndNotVerifiedQueryPresent):
      true
    default:
      false
    }
  }
}

// MARK: - RequestObject

/// A structure representing OpenID Authorization Request
/// https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-authorization-request
public class RequestObject: Codable {

  // MARK: Lifecycle

  init(
    dcqlQuery: Heidi_dcqlDcqlQuery,
    state: String? = nil,
    nonce: String?,
    responseUri: URL?,
    clientMetadata: ClientMetadata?,
    responseType: String,
    clientId: String,
    responseMode: ResponseMode,
    scope: String?,
    identityTrustStatement: IdentityTrustStatement? = nil,
    verificationQueryPublicStatement: VerificationQueryPublicStatement? = nil,
    protectedVerificationAuthorizationTrustStatement: ProtectedVerificationAuthorizationTrustStatement? = nil,
    transactionData: [String]?) throws
  {
    self.dcqlQuery = dcqlQuery
    self.state = state
    self.nonce = nonce
    self.responseUri = responseUri
    self.clientMetadata = clientMetadata
    self.responseType = responseType
    clientIdentifier = try ClientIdentifier(rawClientId: clientId)
    self.responseMode = responseMode
    self.scope = scope
    self.identityTrustStatement = identityTrustStatement
    self.verificationQueryPublicStatement = verificationQueryPublicStatement
    self.protectedVerificationAuthorizationTrustStatement = protectedVerificationAuthorizationTrustStatement
    self.transactionData = transactionData
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    state = try container.decodeIfPresent(String.self, forKey: .state)
    nonce = try container.decodeIfPresent(String.self, forKey: .nonce)
    responseUri = try container.decodeIfPresent(URL.self, forKey: .responseUri)
    clientMetadata = try container.decodeIfPresent(ClientMetadata.self, forKey: .clientMetadata)
    responseType = try container.decode(String.self, forKey: .responseType)
    clientIdentifier = try container.decode(ClientIdentifier.self, forKey: .clientId)
    responseMode = try container.decode(ResponseMode.self, forKey: .responseMode)
    let dcqlQuery = try container.decodeIfPresent(DcqlQuery.self, forKey: .dcqlQuery)
    scope = try container.decodeIfPresent(String.self, forKey: .scope)
    identityTrustStatement = try container.decodeTrustStatement(IdentityTrustStatementJWT.self)
    verificationQueryPublicStatement = try container.decodeTrustStatement(VerificationQueryPublicStatementJWT.self)
    protectedVerificationAuthorizationTrustStatement = try container.decodeTrustStatement(ProtectedVerificationAuthorizationTrustStatementJWT.self)
    self.dcqlQuery = try Self.getVerifiedQuery(for: scope, vqPS: verificationQueryPublicStatement?.payload, dcqlQuery: dcqlQuery).query
    transactionData = try container.decodeIfPresent([String].self, forKey: .transactionData)
  }

  // MARK: Public

  public let state: String?
  public let nonce: String?
  public let responseUri: URL?
  public let clientMetadata: ClientMetadata?
  public let clientIdentifier: ClientIdentifier
  public let responseType: String
  public let dcqlQuery: Heidi_dcqlDcqlQuery
  public let responseMode: ResponseMode
  public let scope: String?
  public let identityTrustStatement: IdentityTrustStatement?
  public let verificationQueryPublicStatement: VerificationQueryPublicStatement?
  public let protectedVerificationAuthorizationTrustStatement: ProtectedVerificationAuthorizationTrustStatement?
  public let transactionData: [String]?
  public var raw: Data?

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(state, forKey: .state)
    try container.encodeIfPresent(nonce, forKey: .nonce)
    try container.encodeIfPresent(responseUri, forKey: .responseUri)
    try container.encodeIfPresent(clientMetadata, forKey: .clientMetadata)
    try container.encode(responseType, forKey: .responseType)
    try container.encode(clientIdentifier, forKey: .clientId)
    try container.encode(responseMode, forKey: .responseMode)
    try container.encodeIfPresent(scope, forKey: .scope)
    try container.encodeIfPresent(transactionData, forKey: .transactionData)
  }

  public func isEqual(to other: RequestObject) -> Bool {
    guard type(of: self) == type(of: other) else { return false }
    return responseMode == other.responseMode &&
      clientIdentifier == other.clientIdentifier &&
      responseType == other.responseType &&
      responseUri == other.responseUri &&
      state == other.state &&
      nonce == other.nonce &&
      clientMetadata == other.clientMetadata &&
      dcqlQuery == other.dcqlQuery &&
      scope == other.scope &&
      identityTrustStatement == other.identityTrustStatement &&
      verificationQueryPublicStatement == other.verificationQueryPublicStatement &&
      protectedVerificationAuthorizationTrustStatement == other.protectedVerificationAuthorizationTrustStatement &&
      transactionData == other.transactionData
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case nonce, state
    case responseUri = "response_uri"
    case clientMetadata = "client_metadata"
    case responseType = "response_type"
    case clientId = "client_id"
    case responseMode = "response_mode"
    case scope
    case verifierInfo = "verifier_info"
    case transactionData = "transaction_data"
    case dcqlQuery = "dcql_query"
  }

  // MARK: Private

  private static func getVerifiedQuery(for scope: String?, vqPS: VerificationQueryPublicStatementJWT?, dcqlQuery: DcqlQuery?) throws -> DcqlQuery {
    if let scope {
      guard dcqlQuery == nil else { throw RequestObjectError.verifiedAndNotVerifiedQueryPresent }
      guard let vqPS else { throw RequestObjectError.missingVQPS }
      guard vqPS.request.scope == scope else { throw RequestObjectError.noQueryFoundOnVQPS }
      return vqPS.request.dcqlQuery
    }
    guard let dcqlQuery else { throw RequestObjectError.missingDcqlQuery }
    return dcqlQuery
  }

}

extension KeyedDecodingContainer<RequestObject.CodingKeys> {
  fileprivate func decodeTrustStatement<T: Decodable, U: JWS<T>>(_ type: T.Type) throws -> U? {
    guard var container = try? nestedUnkeyedContainer(forKey: RequestObject.CodingKeys.verifierInfo) else {
      return nil
    }

    let decoder = JWSDecoder()
    var result: U?
    while !container.isAtEnd {
      let info = try container.decode(RequestObject.VerifierInfo.self)
      let data = Data(info.data.utf8)
      guard let decoded = try? decoder.decode(T.self, from: data) else { continue }
      guard result == nil else { throw RequestObjectError.duplicateTrustStatement }
      result = decoded as? U
    }
    return result
  }
}

// MARK: - RequestObject.ResponseMode

extension RequestObject {
  public enum ResponseMode: String, Codable {
    case directPostJWT = "direct_post.jwt"
    case dcApiJWT = "dc_api.jwt"
  }
}

// MARK: - RequestObject.VerifierInfo

extension RequestObject {
  public struct VerifierInfo: Codable, Equatable {
    public init(format: Format, data: String) {
      self.format = format
      self.data = data
    }

    public let format: Format
    public let data: String

    public enum Format: String, Codable, Equatable {
      case jwt
    }
  }
}

// MARK: - RequestObject + Equatable

extension RequestObject: Equatable {
  public static func == (lhs: RequestObject, rhs: RequestObject) -> Bool {
    lhs.isEqual(to: rhs)
  }
}

public typealias Verifier = ClientMetadata

// MARK: - ClientMetadata

/// Implementation of Human-Readable Client Metadata as of
/// https://datatracker.ietf.org/doc/html/rfc7591#section-2.2
public struct ClientMetadata: Codable, Equatable, Changeable {

  // MARK: Lifecycle

  public init(
    clientName: LocalizedDisplay<String>?,
    logoUri: LocalizedDisplay<URL>?,
    jwks: JWKs?,
    encryptedResponseEncValuesSupported: [String]?)
  {
    self.clientName = clientName
    self.logoUri = logoUri
    self.jwks = jwks
    self.encryptedResponseEncValuesSupported = encryptedResponseEncValuesSupported
  }

  public init(from decoder: Decoder) throws {
    let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
    clientName = try LocalizedDisplay<String>(from: dynamicContainer, withBaseKey: "client_name")
    logoUri = try LocalizedDisplay<URL>(from: dynamicContainer, withBaseKey: "logo_uri")

    let staticContainer = try decoder.container(keyedBy: CodingKeys.self)
    jwks = try staticContainer.decodeIfPresent(JWKs.self, forKey: .jwks)
    encryptedResponseEncValuesSupported = try staticContainer.decodeIfPresent([String].self, forKey: .encryptedResponseEncValuesSupported)
  }

  // MARK: Public

  public let clientName: LocalizedDisplay<String>?
  public let logoUri: LocalizedDisplay<URL>?
  public var jwks: JWKs?
  public var encryptedResponseEncValuesSupported: [String]?

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case jwks
    case encryptedResponseEncValuesSupported = "encrypted_response_enc_values_supported"
  }

}

// MARK: ClientMetadata.JWKs

extension ClientMetadata {
  public struct JWKs: Codable, Equatable {
    public let keys: [JWK]

    public init(keys: [JWK]) {
      self.keys = keys
    }
  }
}
