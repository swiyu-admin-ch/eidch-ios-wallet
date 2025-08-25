import BITNetworking
import Factory
import Foundation
import Moya


enum EIDRequestEndpoint {
  case submit(EIDRequestPayload)
  case getStatus(caseId: String)
  case legalRepresentantVerification(caseId: String)
  case challenge
  case validateAttestations(ValidateAttestationsRequestBody)
  case startOnlineSession(caseId: String)
}

// MARK: TargetType

extension EIDRequestEndpoint: TargetType {
  var baseURL: URL {
    Container.shared.sidUrl()
  }

  var path: String {
    switch self {
    case .submit:
      "api/rest/eid/apply"
    case .getStatus(let caseId):
      "api/rest/eid/\(caseId)/state"
    case .legalRepresentantVerification(let caseId):
      "api/rest/eid/\(caseId)/legal-representant-verification"
    case .validateAttestations:
      "api/rest/attestations/validate"
    case .challenge:
      "api/rest/eid/challenge"
    case .startOnlineSession(let caseId):
      "api/rest/eid/\(caseId)/start-online-session"
    }
  }

  var method: Moya.Method {
    switch self {
    case .submit,
         .validateAttestations: .post
    case .challenge,
         .getStatus,
         .legalRepresentantVerification: .get
    case .startOnlineSession:
      .put
    }
  }

  var task: Moya.Task {
    switch self {
    case .submit(let body as Codable),
         .validateAttestations(let body as Codable):
      .requestJSONEncodable(body)
    case .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .startOnlineSession:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .validateAttestations:
      NetworkHeader.standard.raw
    case .getStatus,
         .legalRepresentantVerification,
         .startOnlineSession,
         .submit:
      nil // Handle by ClientAttestationPlugin
    }
  }
}
