import BITNetworking
import Foundation
import Moya

// MARK: - OpenIDEndpoint

enum OpenIDEndpoint {
  case vcSchema(url: URL)
  case typeMetadata(url: URL)
  case metadata(fromIssuerUrl: URL)
  #warning("TODO: Delete this case after contract updated on OMNI side")
  case fallbackOpenIdConfiguration(issuerUrl: URL)
  case credential(url: URL, body: VcSdJwtCredentialRequestBody, acccessToken: String)
  case accessToken(fromTokenUrl: URL, preAuthorizedCode: String)
  case openIdConfiguration(issuerURL: URL)
  case status(url: URL)
  case publicKeyInfo(jwksUrl: URL)
  case deferredCredential(url: URL, transactionId: String)
}

// MARK: TargetType

extension OpenIDEndpoint: TargetType {

  // MARK: Internal

  var baseURL: URL {
    switch self {
    case .accessToken(let baseUrl, _),
         .credential(let baseUrl, _, _),
         .deferredCredential(let baseUrl, _),
         .fallbackOpenIdConfiguration(let baseUrl),
         .metadata(let baseUrl),
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
    case .fallbackOpenIdConfiguration:
      ".well-known/openid-configuration"
    case .metadata:
      ".well-known/openid-credential-issuer"
    case .openIdConfiguration:
      ".well-known/oauth-authorization-server"
    case .accessToken,
         .credential,
         .deferredCredential,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      "" // The path is already included in the baseUrl of the tokenUrl
    }
  }

  var method: Moya.Method {
    switch self {
    case .fallbackOpenIdConfiguration,
         .metadata,
         .openIdConfiguration,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      .get
    case .accessToken,
         .credential,
         .deferredCredential:
      .post
    }
  }

  var task: Task {
    switch self {
    case .fallbackOpenIdConfiguration,
         .metadata,
         .openIdConfiguration,
         .publicKeyInfo,
         .status,
         .typeMetadata,
         .vcSchema:
      .requestPlain

    case .deferredCredential(_, let transactionId):
      .requestParameters(
        parameters: ["transaction_id": transactionId],
        encoding: JSONEncoding.default)

    case .accessToken(_, let preAuthorizedCode):
      .requestParameters(parameters: [
        "grant_type": "urn:ietf:params:oauth:grant-type:pre-authorized_code",
        "pre-authorized_code": preAuthorizedCode,
      ], encoding: URLEncoding.queryString)

    case .credential(_, let credentialBody, _):
      .requestParameters(
        parameters: credentialBody.asDictionary(),
        encoding: JSONEncoding.default)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .accessToken,
         .deferredCredential,
         .fallbackOpenIdConfiguration,
         .metadata,
         .openIdConfiguration,
         .publicKeyInfo,
         .typeMetadata:
      NetworkHeader.standard.raw
    case .credential(_, _, let token):
      NetworkHeader.authorization(token).raw
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
    case .fallbackOpenIdConfiguration,
         .metadata:
      CredentialMetadata.Mock.sampleData
    case .openIdConfiguration:
      OpenIdConfiguration.Mock.sampleData
    case .accessToken:
      AccessToken.Mock.sampleData
    case .credential:
      CredentialResponse.Mock.sampleData
    default: Data()
    }
  }
  #endif

  // MARK: Private

  private static let keyAccept = "accept"
  private static let valueApplicationStatusList = "application/statuslist+jwt"

  private static let valueApplicationJson = "application/json"
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
