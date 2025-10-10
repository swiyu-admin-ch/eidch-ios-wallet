import BITEIDRequestShared
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
  case pairWallet(caseId: String)
  case startAutoVerification(String, AutoVerificationType)
  case submitFile(caseId: String, file: EIDRequestCaseFile)
  case pairingState(caseId: String, pairingId: String)
}

// MARK: TargetType

extension EIDRequestEndpoint: TargetType {
  var baseURL: URL {
    switch self {
    case .submitFile:
      Container.shared.avBaseUrl()
    case .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState,
         .pairWallet,
         .startAutoVerification,
         .startOnlineSession,
         .submit,
         .validateAttestations:
      Container.shared.sidBaseUrl()
    }
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
    case .pairWallet(let caseId):
      "api/rest/eid/\(caseId)/pair-wallet"
    case .startAutoVerification(let caseId, let autoVerificationType):
      "api/rest/eid/\(caseId)/start-auto-verification/\(autoVerificationType.rawValue)"
    case .submitFile(caseId: let caseId, _):
      "cases/v1/\(caseId)/files"
    case .pairingState(let caseId, let pairingId):
      "api/rest/eid/\(caseId)/pair-wallet/\(pairingId)/state"
    }
  }

  var method: Moya.Method {
    switch self {
    case .submit,
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
    case .submit(let body as Codable),
         .validateAttestations(let body as Codable):
      return .requestJSONEncodable(body)
    case .submitFile(_, file: let file):
      let multipart = MultipartFormData(
        provider: .data(file.data),
        name: file.fileName,
        fileName: file.fileName,
        mimeType: file.mime.mimeType)
      return .uploadMultipart([multipart])
    case .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState,
         .pairWallet,
         .startAutoVerification,
         .startOnlineSession:
      return .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .submitFile,
         .validateAttestations:
      NetworkHeader.standard.raw
    case .getStatus,
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
    case .submitFile:
      .bearer
    default:
      nil
    }
  }

}
