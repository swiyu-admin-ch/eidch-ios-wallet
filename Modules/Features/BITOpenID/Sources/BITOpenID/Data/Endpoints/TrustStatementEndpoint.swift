import BITNetworking
import Foundation
import Moya

// MARK: - TrustStatementEndpoint

enum TrustStatementEndpoint {
  case identity(url: URL, subjectDid: String)
  case vcSchema(url: URL, type: VcSchemaTrustStatementType, vcSchemaId: String)
}

// MARK: - VcSchemaTrustStatementType

public enum VcSchemaTrustStatementType: String, CaseIterable {
  case issuance
  case verification
}

// MARK: - TrustStatementEndpoint + TargetType

extension TrustStatementEndpoint: TargetType {

  var baseURL: URL {
    switch self {
    case .identity(let baseUrl, _),
         .vcSchema(let baseUrl, _, _):
      baseUrl
    }
  }

  var path: String {
    switch self {
    case .identity(_, let did):
      "api/v1/truststatements/identity/\(did)"
    case .vcSchema(_, let type, _):
      "api/v1/truststatements/\(type.rawValue)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .identity,
         .vcSchema:
      .get
    }
  }

  var task: Task {
    switch self {
    case .identity:
      .requestPlain
    case .vcSchema(_, _, let vcSchemaId):
      .requestParameters(parameters: ["vcSchemaId": vcSchemaId], encoding: URLEncoding.default)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .identity,
         .vcSchema:
      NetworkHeader.standard.raw
    }
  }
}
