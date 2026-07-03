import Foundation

// MARK: - PushRegistrationResponse

public struct PushRegistrationResponse: Codable, Equatable {
  public let pushId: String
}

#if DEBUG
extension PushRegistrationResponse {
  // swiftlint:disable force_try
  struct Mock {
    static let sample = PushRegistrationResponse(pushId: "push_id")

    static var sampleData: Data {
      try! JSONEncoder().encode(sample)
    }
  }
}
#endif
