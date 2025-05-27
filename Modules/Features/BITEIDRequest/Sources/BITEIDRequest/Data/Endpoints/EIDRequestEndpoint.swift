import BITNetworking
import Factory
import Foundation
import Moya


enum EIDRequestEndpoint {
  case submit(payload: EIDRequestPayload)
  case getStatus(caseId: String)
  case legalRepresentantVerification(caseId: String)
}

// MARK: TargetType

extension EIDRequestEndpoint: TargetType {
  var baseURL: URL {
    Container.shared.sidUrl()
  }

  var path: String {
    switch self {
    case .submit:
      "eid/apply"
    case .getStatus(let caseId):
      "eid/\(caseId)/state"
    case .legalRepresentantVerification(let caseId):
      "eid/\(caseId)/legal-representant-verification"
    }
  }

  var method: Moya.Method {
    switch self {
    case .submit: .post
    case .getStatus,
         .legalRepresentantVerification: .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .submit(let payload):
      .requestParameters(parameters: payload.asDictionary(), encoding: JSONEncoding.default)
    case .getStatus,
         .legalRepresentantVerification:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .getStatus,
         .legalRepresentantVerification,
         .submit:
      NetworkHeader.standard.raw
    }
  }
}
