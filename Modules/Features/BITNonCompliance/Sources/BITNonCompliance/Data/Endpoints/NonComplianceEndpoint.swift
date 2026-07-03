import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - NonComplianceEndpoint

enum NonComplianceEndpoint {
  case challenge
  case report(Encodable)
  case nonCompliantActors(url: URL)
}

// MARK: TargetType

extension NonComplianceEndpoint: TargetType {

  var baseURL: URL {
    switch self {
    case .challenge,
         .report: Container.shared.nonComplianceBaseURL()
    case .nonCompliantActors(let baseUrl): baseUrl
    }
  }

  var path: String {
    switch self {
    case .challenge: "mobile-api/v1/challenge"
    case .report: "mobile-api/v1/cases/non-compliant-actors"
    case .nonCompliantActors: "api/v1/non-compliant-actors"
    }
  }

  var method: Moya.Method {
    switch self {
    case .challenge,
         .nonCompliantActors: .get
    case .report: .post
    }
  }

  var task: Moya.Task {
    switch self {
    case .report(let report): .requestCustomJSONEncodable(report, encoder: Container.shared.nonComplianceJsonEncoder())
    case .challenge,
         .nonCompliantActors: .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .nonCompliantActors: NetworkHeader.standard.raw
    case .report: nil // handled by ClientAttestationPlugin
    }
  }
}
