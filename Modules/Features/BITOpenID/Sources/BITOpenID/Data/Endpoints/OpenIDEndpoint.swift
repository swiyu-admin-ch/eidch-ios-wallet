import BITCore
import BITNetworking
import Foundation
import Moya

// MARK: - OpenIDEndpoint

enum OpenIDEndpoint {
  case vcSchema(url: URL)
  case typeMetadata(url: URL)
  case metadata(fromIssuerUrl: URL)
  case oidConnectMetadata(fromIssuerUrl: URL)
  case credential(url: URL, body: CredentialRequestBody, accessToken: AccessToken, dpopProof: String?)
  case accessToken(fromTokenUrl: URL, preAuthorizedCode: String, dpopProof: String?)
  case refreshAccessToken(fromTokenUrl: URL, refreshToken: String, dpopProof: String?)
  case nonce(url: URL)
  case openIdConfiguration(fromIssuerUrl: URL)
  case oidConnectOpenIdConfiguration(fromIssuerUrl: URL)
  case status(url: URL)
  case publicKeyInfo(jwksUrl: URL)
  case deferredCredential(url: URL, body: DeferredCredentialRequestBody, accessToken: AccessToken, dpopProof: String?)
}

// MARK: TargetType

extension OpenIDEndpoint: TargetType {

  // MARK: Internal

  var baseURL: URL {
    switch self {
    case .accessToken(let baseUrl, _, _),
         .credential(let baseUrl, _, _, _),
         .deferredCredential(let baseUrl, _, _, _),
         .nonce(let baseUrl),
         .oidConnectMetadata(let baseUrl),
         .oidConnectOpenIdConfiguration(let baseUrl),
         .publicKeyInfo(let baseUrl),
         .refreshAccessToken(let baseUrl, _, _),
         .status(let baseUrl),
         .typeMetadata(let baseUrl),
         .vcSchema(let baseUrl):
      baseUrl
    case .metadata(let baseUrl),
         .openIdConfiguration(let baseUrl):
      baseUrl.deletingPathAndQuery ?? baseUrl
    }
  }

  var path: String {
    switch self {
    case .metadata(let baseUrl):
      ".well-known/openid-credential-issuer" + baseUrl.path()
    case .oidConnectMetadata:
      ".well-known/openid-credential-issuer"
    case .openIdConfiguration(let baseUrl):
      ".well-known/oauth-authorization-server" + baseUrl.path()
    case .oidConnectOpenIdConfiguration:
      ".well-known/oauth-authorization-server"
    case .accessToken,
         .credential,
         .deferredCredential,
         .nonce,
         .publicKeyInfo,
         .refreshAccessToken,
         .status,
         .typeMetadata,
         .vcSchema:
      "" // The path is already included in the baseUrl of the tokenUrl
    }
  }

  var method: Moya.Method {
    switch self {
    case .metadata,
         .oidConnectMetadata,
         .oidConnectOpenIdConfiguration,
         .openIdConfiguration,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      .get
    case .accessToken,
         .credential,
         .deferredCredential,
         .nonce,
         .refreshAccessToken:
      .post
    }
  }

  var task: Task {
    switch self {
    case .metadata,
         .nonce,
         .oidConnectMetadata,
         .oidConnectOpenIdConfiguration,
         .openIdConfiguration,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      .requestPlain

    case .deferredCredential(_, let body, _, _):
      switch body {
      case .json(let request):
        .requestParameters(
          parameters: request.asDictionary(),
          encoding: JSONEncoding.default)
      case .jwe(let token):
        .requestData(Data(token.utf8))
      }

    case .accessToken(_, let preAuthorizedCode, _):
      .requestParameters(parameters: [
        "grant_type": "urn:ietf:params:oauth:grant-type:pre-authorized_code",
        "pre-authorized_code": preAuthorizedCode,
      ], encoding: URLEncoding.httpBody)

    case .refreshAccessToken(_, let refreshToken, _):
      .requestParameters(parameters: [
        "grant_type": "refresh_token",
        "refresh_token": refreshToken,
      ], encoding: URLEncoding.httpBody)

    case .credential(_, let credentialBody, _, _):
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
      return NetworkHeader.standard.raw
    case .metadata,
         .oidConnectMetadata:
      return [
        NetworkHeader.accept("\(ContentType.jwt.rawValue), \(ContentType.json.rawValue)"),
        NetworkHeader.acceptLanguage(UserLocale.LocaleIdentifier.allCases.map(\.rawValue)),
      ].raw
    case .oidConnectOpenIdConfiguration,
         .openIdConfiguration:
      return [
        NetworkHeader.accept("\(ContentType.jwt.rawValue), \(ContentType.json.rawValue)"),
      ].raw
    case .credential(_, let body, let accessToken, let dpopProof):
      var headers = [
        NetworkHeader.authorization(value: "\(accessToken.tokenType.rawValue) \(accessToken.accessToken)"),
        NetworkHeader.swiyuAPIVersion("2"),
        NetworkHeader.contentType(body.contentType.rawValue),
        NetworkHeader.accept("\(ContentType.json.rawValue), \(ContentType.jwt.rawValue)"),
      ]
      if let dpopProof {
        headers.append(.dpop(dpopProof))
      }
      return headers.raw
    case .accessToken(_, _, let dpopProof):
      var headers = [
        NetworkHeader.formUrlEncoded,
        NetworkHeader.swiyuAPIVersion("2"),
      ]
      if let dpopProof {
        headers.append(.dpop(dpopProof))
      }
      return headers.raw
    case .refreshAccessToken(_, _, let dpopProof):
      var headers = [
        NetworkHeader.formUrlEncoded,
        NetworkHeader.swiyuAPIVersion("2"),
      ]
      if let dpopProof {
        headers.append(.dpop(dpopProof))
      }
      return headers.raw
    case .deferredCredential(_, let body, let accessToken, let dpopProof):
      var headers = [
        NetworkHeader.authorization(value: "\(accessToken.tokenType.rawValue) \(accessToken.accessToken)"),
        NetworkHeader.swiyuAPIVersion("2"),
        NetworkHeader.contentType(body.contentType.rawValue),
        NetworkHeader.accept("\(ContentType.json.rawValue), \(ContentType.jwt.rawValue)"),
      ]
      if let dpopProof {
        headers.append(.dpop(dpopProof))
      }
      return headers.raw
    case .status:
      return [ Self.keyAccept: Self.valueApplicationStatusList ]
    case .vcSchema:
      return [
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
    case .oidConnectMetadata:
      CredentialIssuerMetadata.Mock.sampleData
    case .metadata:
      CredentialIssuerMetadata.Mock.sampleData
    case .openIdConfiguration:
      OpenIdConfiguration.Mock.sampleData
    case .oidConnectOpenIdConfiguration:
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
