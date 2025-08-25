import BITNetworking
import Foundation
import Moya

// MARK: - VersionEnforcementEndpoint

enum VersionEnforcementEndpoint {
  case configuration(versionEnforcementUrl: URL)
}

// MARK: TargetType

extension VersionEnforcementEndpoint: TargetType {
  var baseURL: URL {
    switch self {
    case .configuration(let versionEnforcementUrl):
      versionEnforcementUrl
    }
  }

  var path: String {
    switch self {
    case .configuration:
      "" // The path is already included in the versionEnforcementUrl
    }
  }

  var method: Moya.Method {
    switch self {
    case .configuration:
      .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .configuration:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .configuration:
      NetworkHeader.form.raw
    }
  }

  #if DEBUG
  var sampleData: Data {
    switch self {
    case .configuration:
      VersionEnforcement.Mock.sampleData
    }
  }
  #endif

}
