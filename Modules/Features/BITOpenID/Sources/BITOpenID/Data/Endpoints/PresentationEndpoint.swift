import Alamofire
import BITNetworking
import Foundation
import Moya

// MARK: - PresentationEndpoint

enum PresentationEndpoint {
  case requestObject(url: URL)
  case submission(url: URL, jwe: String)
  case errorSubmission(url: URL, presentationErrorBody: PresentationErrorRequestBody)
}

// MARK: TargetType

extension PresentationEndpoint: TargetType {
  var baseURL: URL {
    switch self {
    case .errorSubmission(url: let url, _),
         .requestObject(let url),
         .submission(let url, _):
      url
    }
  }

  var path: String {
    switch self {
    case .errorSubmission,
         .requestObject,
         .submission:
      ""
    }
  }

  var method: Moya.Method {
    switch self {
    case .requestObject:
      .get
    case .errorSubmission,
         .submission: .post
    }
  }

  var task: Moya.Task {
    switch self {
    case .requestObject:
      .requestPlain
    case .submission(_, jwe: let jwe):
      .requestParameters(parameters: ["response": jwe], encoding: URLEncoding.httpBody)
    case .errorSubmission(_, presentationErrorBody: let presentationErrorBody):
      .requestParameters(parameters: presentationErrorBody.asDictionary(), encoding: URLEncoding.httpBody)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .requestObject: [
        NetworkHeader.accept("application/oauth-authz-req+jwt, application/jwt"),
      ].raw
    case .errorSubmission:
      [
        NetworkHeader.form,
      ].raw
    case .submission:
      [
        NetworkHeader.form,
        NetworkHeader.swiyuAPIVersion("2"),
      ].raw
    }
  }
}
