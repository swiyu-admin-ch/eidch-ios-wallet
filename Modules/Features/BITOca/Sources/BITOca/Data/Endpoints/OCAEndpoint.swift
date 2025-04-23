import BITNetworking
import Foundation
import Moya

// MARK: - OCAEndpoint

enum OCAEndpoint {
  case bundle(url: URL)
}

// MARK: TargetType

extension OCAEndpoint: TargetType {
  var baseURL: URL {
    switch self {
    case .bundle(let baseUrl):
      baseUrl
    }
  }

  var path: String {
    switch self {
    case .bundle:
      ""
    }
  }

  var method: Moya.Method {
    switch self {
    case .bundle:
      .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .bundle:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .bundle:
      NetworkHeader.standard.raw
    }
  }
}
