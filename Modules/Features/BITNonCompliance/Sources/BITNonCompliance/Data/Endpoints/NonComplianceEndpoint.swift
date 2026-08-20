import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - NonComplianceEndpoint

enum NonComplianceEndpoint {
  case challenge
  case report(Encodable)
  case nonComplianceTrustList(url: URL)
}

// MARK: TargetType

extension NonComplianceEndpoint: TargetType {

  var baseURL: URL {
    switch self {
    case .challenge,
         .report: Container.shared.nonComplianceBaseURL()
    case .nonComplianceTrustList(let baseUrl): baseUrl
    }
  }

  var path: String {
    switch self {
    case .challenge: "mobile-api/v1/challenge"
    case .report: "mobile-api/v1/cases/non-compliant-actors"
    case .nonComplianceTrustList: "api/v2/non-compliance-trust-list"
    }
  }

  var method: Moya.Method {
    switch self {
    case .challenge,
         .nonComplianceTrustList: .get
    case .report: .post
    }
  }

  var task: Moya.Task {
    switch self {
    case .report(let report): .requestCustomJSONEncodable(report, encoder: Container.shared.nonComplianceJsonEncoder())
    case .challenge,
         .nonComplianceTrustList: .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .nonComplianceTrustList: NetworkHeader.standard.raw
    case .report: nil // handled by ClientAttestationPlugin
    }
  }
}
