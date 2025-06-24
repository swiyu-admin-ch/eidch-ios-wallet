import BITNetworking
import Foundation
import Moya

// MARK: - OpenIDEndpoint

enum OpenIDEndpoint {
  case vcSchema(url: URL)
  case typeMetadata(url: URL)
  case metadata(fromIssuerUrl: URL)
  case credential(url: URL, body: VcSdJwtCredentialRequestBody, acccessToken: String)
  case accessToken(fromTokenUrl: URL, preAuthorizedCode: String)
  case openIdConfiguration(issuerURL: URL)
  case status(url: URL)
  case publicKeyInfo(jwksUrl: URL)
  case requestObject(url: URL)
  case trustStatements(url: URL, issuerDid: String)
}

// MARK: TargetType

extension OpenIDEndpoint: TargetType {
  var baseURL: URL {
    switch self {
    case .accessToken(let baseUrl, _),
         .credential(let baseUrl, _, _),
         .metadata(let baseUrl),
         .openIdConfiguration(let baseUrl),
         .publicKeyInfo(let baseUrl),
         .requestObject(let baseUrl),
         .status(let baseUrl),
         .trustStatements(let baseUrl, _),
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
      ".well-known/openid-configuration"
    case .trustStatements(_, let did):
      "api/v1/truststatements/\(did)"
    case .accessToken,
         .credential,
         .publicKeyInfo,
         .requestObject,
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
         .requestObject,
         .status,
         .trustStatements,
         .typeMetadata,
         .vcSchema:
      .get
    case .accessToken,
         .credential:
      .post
    }
  }

  var task: Task {
    switch self {
    case .metadata,
         .openIdConfiguration,
         .publicKeyInfo,
         .requestObject,
         .status,
         .trustStatements,
         .typeMetadata,
         .vcSchema:
      .requestPlain

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
         .metadata,
         .openIdConfiguration,
         .publicKeyInfo,
         .requestObject,
         .trustStatements,
         .typeMetadata:
      NetworkHeader.standard.raw
    case .credential(_, _, let token):
      NetworkHeader.authorization(token).raw
    case .status:
      NetworkHeader.statusList.raw
    case .vcSchema:
      NetworkHeader.vcSchema.raw
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
      CredentialResponse.Mock.sampleData
    default: Data()
    }
  }
  #endif
}
