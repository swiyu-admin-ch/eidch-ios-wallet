import Foundation

// MARK: - PushUpdateResponseError

struct PushUpdateResponseError: Codable, Equatable {
  let pushId: String
  let code: Code

  enum Code: String, Codable {
    case notFound = "NOT_FOUND"
  }

  private enum CodingKeys: String, CodingKey {
    case pushId = "push_id"
    case code
  }
}

#if DEBUG
extension PushUpdateResponseError {
  struct Mock {
    static let sample = PushUpdateResponseError(pushId: "pushId", code: .notFound)
  }
}
#endif
