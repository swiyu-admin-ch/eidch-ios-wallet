import BITEIDRequestShared
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - AVRepositoryEndpoint

enum AVRepositoryEndpoint {
  case submitFile(caseId: String, file: EIDRequestCaseFile)
  case submit(caseId: String, body: Data)
}

// MARK: TargetType

extension AVRepositoryEndpoint: TargetType {
  var baseURL: URL {
    Container.shared.avBaseUrl()
  }

  var path: String {
    switch self {
    case .submitFile(caseId: let caseId, _):
      "cases/v2/\(caseId)/files"
    case .submit(let caseId, _):
      "cases/v2/\(caseId)/submit"
    }
  }

  var method: Moya.Method {
    .post
  }

  var task: Moya.Task {
    switch self {
    case .submitFile(_, file: let file):
      .requestData(file.data)
    case .submit(_, let body):
      .requestData(body)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .submitFile(_, let file):
      [
        "Content-Disposition": "attachment; filename=\"\(file.fileName)\"",
        "Content-Type": file.mime.mimeType,
      ]
    case .submit:
      NetworkHeader.contentType(ContentType.json.rawValue).raw
    }
  }
}
