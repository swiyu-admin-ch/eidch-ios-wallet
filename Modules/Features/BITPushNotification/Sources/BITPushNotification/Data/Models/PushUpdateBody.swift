import Foundation

// MARK: - PushUpdateBody

public struct PushUpdateBody: Codable, Equatable {

  public init(pushIds: [String], pushDeviceToken: String) {
    self.pushIds = pushIds
    self.pushDeviceToken = pushDeviceToken
  }

  let pushIds: [String]
  let pushDeviceToken: String

  private enum CodingKeys: String, CodingKey {
    case pushIds = "push_ids"
    case pushDeviceToken = "push_device_token"
  }
}

#if DEBUG
extension PushUpdateBody {
  struct Mock {
    static let sample = PushUpdateBody(pushIds: ["push_id_1", "push_id_2"], pushDeviceToken: "push_device_token")
  }
}
#endif
