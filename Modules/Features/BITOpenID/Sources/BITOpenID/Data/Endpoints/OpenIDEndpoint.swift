import BITNetworking
import Foundation
import Moya

// MARK: - OpenIDEndpoint

enum OpenIDEndpoint {
  case vcSchema(url: URL)
  case typeMetadata(url: URL)
  case metadata(fromIssuerUrl: URL)
  case credential(url: URL, body: CredentialRequestBody, accessToken: AccessToken)
  case accessToken(fromTokenUrl: URL, preAuthorizedCode: String)
  case nonce(url: URL)
  case openIdConfiguration(issuerURL: URL)
  case status(url: URL)
  case publicKeyInfo(jwksUrl: URL)
  case deferredCredential(url: URL, body: DeferredCredentialRequestBody, accessToken: String)
}

// MARK: TargetType

extension OpenIDEndpoint: TargetType {

  // MARK: Internal

  var baseURL: URL {
    switch self {
    case .accessToken(let baseUrl, _),
         .credential(let baseUrl, _, _),
         .deferredCredential(let baseUrl, _, _),
         .metadata(let baseUrl),
         .nonce(let baseUrl),
         .openIdConfiguration(let baseUrl),
         .publicKeyInfo(let baseUrl),
         .status(let baseUrl),
         .typeMetadata(let baseUrl),
         .vcSchema(let baseUrl):
      baseUrl
    }
  }

  var path: String {
    switch self {
    case .metadata:
      ".well-known/openid-credential-issuer"
    case .openIdConfiguration:
      ".well-known/oauth-authorization-server"
    case .accessToken,
         .credential,
         .deferredCredential,
         .nonce,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      "" // The path is already included in the baseUrl of the tokenUrl
    }
  }

  var method: Moya.Method {
    switch self {
    case .metadata,
         .openIdConfiguration,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      .get
    case .accessToken,
         .credential,
         .deferredCredential,
         .nonce:
      .post
    }
  }

  var task: Task {
    switch self {
    case .metadata,
         .nonce,
         .openIdConfiguration,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      .requestPlain

    case .deferredCredential(_, let body, _):
      switch body {
      case .json(let request):
        .requestParameters(
          parameters: request.asDictionary(),
          encoding: JSONEncoding.default)
      case .jwe(let token):
        .requestData(Data(token.utf8))
      }

    case .accessToken(_, let preAuthorizedCode):
      .requestParameters(parameters: [
        "grant_type": "urn:ietf:params:oauth:grant-type:pre-authorized_code",
        "pre-authorized_code": preAuthorizedCode,
      ], encoding: URLEncoding.queryString)

    case .credential(_, let credentialBody, _):
      switch credentialBody {
      case .json(let request):
        .requestParameters(
          parameters: request.asDictionary(),
          encoding: JSONEncoding.default)
      case .jwe(let token):
        .requestData(Data(token.utf8))
      }
    }
  }

  var headers: [String: String]? {
    switch self {
    case .nonce,
         .publicKeyInfo,
         .typeMetadata:
      NetworkHeader.standard.raw
    case .metadata,
         .openIdConfiguration: [
        NetworkHeader.accept("\(ContentType.jwt.rawValue), \(ContentType.json.rawValue)"),
      ].raw
    case .credential(_, let body, let accessToken):
      [
        NetworkHeader.authorization(value: "\(accessToken.tokenType.rawValue) \(accessToken.accessToken)"),
        NetworkHeader.swiyuAPIVersion("2"),
        NetworkHeader.contentType(body.contentType.rawValue),
        NetworkHeader.accept("\(ContentType.json.rawValue), \(ContentType.jwt.rawValue)"),
      ].raw
    case .accessToken:
      [
        NetworkHeader.standard,
        NetworkHeader.swiyuAPIVersion("2"),
      ].raw
    case .deferredCredential(_, let body, let accessToken):
      // OAuth 2.0 access token to be implemented with batch issuance feature
      [
        NetworkHeader.authorization(value: "Bearer \(accessToken)"),
        NetworkHeader.swiyuAPIVersion("2"),
        NetworkHeader.contentType(body.contentType.rawValue),
        NetworkHeader.accept("\(ContentType.json.rawValue), \(ContentType.jwt.rawValue)"),
      ].raw
    case .status: [ Self.keyAccept: Self.valueApplicationStatusList ]
    case .vcSchema: [
        Self.keyAccept: [
          Self.valueApplicationJson,
          Self.valueApplicationVcSchema,
          Self.valueApplicationVcSchemaInstance,
        ].joined(separator: ", "),
      ]
    }
  }

  #if DEBUG
  var sampleData: Data {
    switch self {
    case .metadata:
      CredentialMetadata.Mock.sampleData
    case .openIdConfiguration:
      OpenIdConfiguration.Mock.sampleData
    case .accessToken:
      AccessToken.Mock.sampleData
    case .credential:
      CredentialResponseImmediate.Mock.sampleData
    default: Data()
    }
  }
  #endif

  // MARK: Private

  private static let keyAccept = "accept"
  private static let valueApplicationStatusList = "application/statuslist+jwt"

  private static let valueApplicationJson = "application/json"
  private static let valueApplicationJWT = "application/jwt"
  private static let valueApplicationFormUrlEncoded = "application/x-www-form-urlencoded"
  private static let valueApplicationVcSchema = "application/schema+json"
  private static let valueApplicationVcSchemaInstance = "application/schema-instance+json"
}

// MARK: AccessTokenAuthorizable

extension OpenIDEndpoint: AccessTokenAuthorizable {

  var authorizationType: AuthorizationType? {
    switch self {
    case .deferredCredential:
      .bearer
    default:
      nil
    }
  }

}
