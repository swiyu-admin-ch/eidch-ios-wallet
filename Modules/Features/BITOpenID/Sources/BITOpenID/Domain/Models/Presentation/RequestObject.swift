import AnyCodable
import BITCore
import BITCrypto
import BITJWT
import BITSwiyuSharedKMP
import Foundation

// MARK: - RequestObjectError

public enum RequestObjectError: Error, Equatable {
  case invalidPayload(_ underlyingError: Error? = nil)
  case invalidQuery
  case missingQuery

  public static func == (lhs: RequestObjectError, rhs: RequestObjectError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidPayload, .invalidPayload),
         (.invalidQuery, .invalidQuery),
         (.missingQuery, .missingQuery):
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
    dcqlQuery: DcqlQuery?,
    state: String? = nil,
    nonce: String?,
    responseUri: URL?,
    clientMetadata: ClientMetadata?,
    responseType: String,
    clientId: String,
    responseMode: ResponseMode,
    transactionData: [String]?)
  {
    self.dcqlQuery = dcqlQuery
    self.state = state
    self.nonce = nonce
    self.responseUri = responseUri
    self.clientMetadata = clientMetadata
    self.responseType = responseType
    self.clientId = clientId
    self.responseMode = responseMode
    self.transactionData = transactionData
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    state = try container.decodeIfPresent(String.self, forKey: .state)
    nonce = try container.decodeIfPresent(String.self, forKey: .nonce)
    responseUri = try container.decodeIfPresent(URL.self, forKey: .responseUri)
    clientMetadata = try container.decodeIfPresent(ClientMetadata.self, forKey: .clientMetadata)
    responseType = try container.decode(String.self, forKey: .responseType)
    clientId = try container.decode(String.self, forKey: .clientId)
    responseMode = try container.decode(ResponseMode.self, forKey: .responseMode)
    transactionData = try container.decodeIfPresent([String].self, forKey: .transactionData)

    guard let query = try container.decodeIfPresent(AnyCodable.self, forKey: .dcqlQuery) else {
      dcqlQuery = nil
      return
    }

    let data = try JSONEncoder().encode(query)
    guard let json = String(data: data, encoding: .utf8) else {
      throw RequestObjectError.invalidQuery
    }

    dcqlQuery = try DcqlSupport().decodeDcqlQuery(json: json)
  }

  // MARK: Public

  public let state: String?
  public let nonce: String?
  public let responseUri: URL?
  public let clientMetadata: ClientMetadata?
  public let responseType: String
  public let clientId: String
  public let dcqlQuery: DcqlQuery?
  public let responseMode: ResponseMode
  public let transactionData: [String]?
  public var raw: Data?

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(state, forKey: .state)
    try container.encodeIfPresent(nonce, forKey: .nonce)
    try container.encodeIfPresent(responseUri, forKey: .responseUri)
    try container.encodeIfPresent(clientMetadata, forKey: .clientMetadata)
    try container.encodeIfPresent(responseType, forKey: .responseType)
    try container.encodeIfPresent(clientId, forKey: .clientId)
    try container.encode(responseMode, forKey: .responseMode)
    try container.encodeIfPresent(transactionData, forKey: .transactionData)
  }

  public func isEqual(to other: RequestObject) -> Bool {
    guard type(of: self) == type(of: other) else { return false }
    return responseMode == other.responseMode &&
      clientId == other.clientId &&
      responseType == other.responseType &&
      responseUri == other.responseUri &&
      state == other.state &&
      nonce == other.nonce &&
      clientMetadata == other.clientMetadata &&
      dcqlQuery?.isEqual(other.dcqlQuery) ?? false &&
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
    case transactionData = "transaction_data"
    case dcqlQuery = "dcql_query"
  }
}

// MARK: RequestObject.ResponseMode

extension RequestObject {
  public enum ResponseMode: String, Codable {
    case directPost = "direct_post"
    case directPostJWT = "direct_post.jwt"
    case dcApiJWT = "dc_api.jwt"
  }
}

// MARK: Equatable

extension RequestObject: Equatable {
  public static func == (lhs: RequestObject, rhs: RequestObject) -> Bool {
    lhs.isEqual(to: rhs)
  }
}

public typealias Verifier = ClientMetadata

// MARK: - ClientMetadata

/// Implementation of Human-Readable Client Metadata as of
/// https://datatracker.ietf.org/doc/html/rfc7591#section-2.2
public struct ClientMetadata: Codable, Equatable {

  // MARK: Lifecycle

  public init(
    clientName: LocalizedDisplay<String>?,
    logoUri: LocalizedDisplay<URL>?,
    jwks: JWKs? = nil,
    encryptedResponseEncValuesSupported: [String]? = nil) throws
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
  public let jwks: JWKs?
  public let encryptedResponseEncValuesSupported: [String]?

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
