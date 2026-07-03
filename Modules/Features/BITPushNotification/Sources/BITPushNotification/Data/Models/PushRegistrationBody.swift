import Foundation

// MARK: - PushRegistrationBody

public struct PushRegistrationBody: Codable, Equatable {

  public init(pushDeviceToken: String, platform: String) {
    self.pushDeviceToken = pushDeviceToken
    self.platform = platform
  }

  let platform: String
  let pushDeviceToken: String

  private enum CodingKeys: String, CodingKey {
    case pushDeviceToken = "push_device_token"
    case platform = "platform_os"
  }
}

#if DEBUG
extension PushRegistrationBody {
  struct Mock {
    static let sample = PushRegistrationBody(pushDeviceToken: "push_device_token", platform: "ios")
  }
}
#endif
