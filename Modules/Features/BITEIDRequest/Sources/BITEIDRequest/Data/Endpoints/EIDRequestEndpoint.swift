import BITEIDRequestShared
import BITNetworking
import Factory
import Foundation
import Moya


enum EIDRequestEndpoint {
  case apply(EIDRequestPayload)
  case getStatus(caseId: String)
  case legalRepresentantVerification(caseId: String)
  case challenge
  case validateAttestations(ValidateAttestationsRequestBody)
  case startOnlineSession(caseId: String)
  case pairWallet(caseId: String)
  case startAutoVerification(caseId: String, autoVerificationType: AutoVerificationType, isNFCAvailable: Bool)
  case submitFile(caseId: String, file: EIDRequestCaseFile)
  case submit(caseId: String)
  case pairingState(caseId: String, pairingId: String)
}

// MARK: TargetType

extension EIDRequestEndpoint: TargetType {
  var baseURL: URL {
    switch self {
    case .submit,
         .submitFile:
      Container.shared.avBaseUrl()
    case .apply,
         .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState,
         .pairWallet,
         .startAutoVerification,
         .startOnlineSession,
         .validateAttestations:
      Container.shared.sidBaseUrl()
    }
  }

  var path: String {
    switch self {
    case .apply:
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
    case .pairWallet(let caseId):
      "api/rest/eid/\(caseId)/pair-wallet"
    case .startAutoVerification(let caseId, let autoVerificationType, _):
      "api/rest/eid/\(caseId)/start-auto-verification/\(autoVerificationType.rawValue)"
    case .pairingState(let caseId, let pairingId):
      "api/rest/eid/\(caseId)/pair-wallet/\(pairingId)/state"
    case .submitFile(caseId: let caseId, _):
      "cases/v1/\(caseId)/files"
    case .submit(let caseId):
      "cases/v1/\(caseId)/submit"
    }
  }

  var method: Moya.Method {
    switch self {
    case .apply,
         .submit,
         .submitFile,
         .validateAttestations: .post
    case .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState: .get
    case .pairWallet,
         .startAutoVerification,
         .startOnlineSession: .put
    }
  }

  var task: Moya.Task {
    switch self {
    case .apply(let body as Codable),
         .validateAttestations(let body as Codable):
      .requestJSONEncodable(body)
    case .submitFile(_, file: let file):
      .requestData(file.data)
    case .startAutoVerification(_, _, let isNFCAvailable):
      .requestParameters(parameters: ["nfcAvailable": isNFCAvailable], encoding: URLEncoding.queryString)
    case .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState,
         .pairWallet,
         .startOnlineSession,
         .submit:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .submitFile(_, let file):
      [
        "Content-Disposition": "attachment; filename=\"\(file.fileName)\"",
        "Content-Type": "application/octet-stream",
      ]
    case .challenge,
         .validateAttestations:
      NetworkHeader.standard.raw
    case .apply,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState,
         .pairWallet,
         .startAutoVerification,
         .startOnlineSession,
         .submit:
      nil // Handle by ClientAttestationPlugin
    }
  }
}

// MARK: AccessTokenAuthorizable

extension EIDRequestEndpoint: AccessTokenAuthorizable {

  var authorizationType: AuthorizationType? {
    switch self {
    case .submit,
         .submitFile:
      .bearer
    default:
      nil
    }
  }

}
