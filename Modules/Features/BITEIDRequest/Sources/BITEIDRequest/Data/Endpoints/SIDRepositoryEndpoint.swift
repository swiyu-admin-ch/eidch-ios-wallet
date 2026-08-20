import BITEIDRequestShared
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - SIDRepositoryEndpoint

enum SIDRepositoryEndpoint {
  case apply(EIDRequestPayload)
  case getStatus(caseId: String)
  case legalRepresentantVerification(caseId: String)
  case challenge
  case validateAttestations(ValidateAttestationsRequestBody)
  case startOnlineSession(caseId: String)
  case pairWallet(caseId: String)
  case startAutoVerification(caseId: String, autoVerificationType: AutoVerificationType, isNFCAvailable: Bool)
  case pairingState(caseId: String, pairingId: String)
  case registerPushId(caseId: String, body: PushIdRegistrationBody)
  case abort(caseId: String)
}

// MARK: TargetType

extension SIDRepositoryEndpoint: TargetType {
  var baseURL: URL {
    Container.shared.sidBaseUrl()
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
    case .registerPushId(let caseId, _):
      "api/rest/eid/\(caseId)/peer-push-id"
    case .abort(let caseId):
      "api/rest/eid/\(caseId)/abort"
    }
  }

  var method: Moya.Method {
    switch self {
    case .apply,
         .validateAttestations: .post
    case .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState: .get
    case .abort,
         .pairWallet,
         .registerPushId,
         .startAutoVerification,
         .startOnlineSession: .put
    }
  }

  var task: Moya.Task {
    switch self {
    case .apply(let body as Codable),
         .registerPushId(_, let body as Codable),
         .validateAttestations(let body as Codable):
      .requestJSONEncodable(body)
    case .startAutoVerification(_, _, let isNFCAvailable):
      .requestParameters(parameters: ["nfcAvailable": isNFCAvailable], encoding: URLEncoding.queryString)
    case .abort,
         .challenge,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState,
         .pairWallet,
         .startOnlineSession:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .validateAttestations:
      NetworkHeader.standard.raw
    case .abort,
         .apply,
         .getStatus,
         .legalRepresentantVerification,
         .pairingState,
         .pairWallet,
         .registerPushId,
         .startAutoVerification,
         .startOnlineSession:
      nil // Handle by ClientAttestationPlugin
    }
  }
}
