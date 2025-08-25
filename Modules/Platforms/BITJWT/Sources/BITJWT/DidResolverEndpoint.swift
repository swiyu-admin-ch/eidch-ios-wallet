import BITNetworking
import Foundation
import Moya

// MARK: - DidResolverEndpoint

enum DidResolverEndpoint {
  case didLog(url: URL)
}

// MARK: TargetType

extension DidResolverEndpoint: TargetType {

  // MARK: Internal

  var baseURL: URL {
    switch self {
    case .didLog(let url): url
    }
  }

  var path: String {
    switch self {
    case .didLog: ""
    }
  }

  var method: Moya.Method {
    switch self {
    case .didLog:
      .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .didLog:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .didLog: [ Self.keyContentType: Self.valueApplicationJsonLines ]
    }
  }

  // MARK: Private

  private static let keyContentType = "Content-Type"
  private static let valueApplicationJsonLines = "application/jsonl+json"
}
