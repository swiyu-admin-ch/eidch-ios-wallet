import BITAppAttestation
import BITNetworking
import Factory
import Foundation
import Moya


enum EIDRequestEndpoint {
  case submit(request: ClientAttestedRequest)
  case getStatus(caseId: String)
  case legalRepresentantVerification(caseId: String)
  case challenge
  case validateAttestations(ValidateAttestationsRequestBody)
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
    }
  }

  var method: Moya.Method {
    switch self {
    case .submit,
         .validateAttestations: .post
    case .challenge,
         .getStatus,
         .legalRepresentantVerification: .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .submit(let request):
      .requestParameters(parameters: request.body.asDictionary(), encoding: JSONEncoding.default)
    case .validateAttestations(let body):
      .requestParameters(parameters: body.asDictionary(), encoding: JSONEncoding.default)
    case .challenge,
         .getStatus,
         .legalRepresentantVerification:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .validateAttestations:
      NetworkHeader.standard.raw
    case .submit(let request):
      NetworkHeader.keyAttestation(clientAttestation: request.header.clientAttestation, clientAttestationPop: request.header.clientAttestationPoP).raw
    }
  }
}
