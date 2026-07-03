import Foundation

// MARK: - PushUpdateResponse

public struct PushUpdateResponse: Codable, Equatable {
  let successes: [String]
  let failures: [PushUpdateResponseError]

  private enum CodingKeys: String, CodingKey {
    case successes
    case failures
  }
}

#if DEBUG
extension PushUpdateResponse {
  // swiftlint:disable force_try
  struct Mock {
    static let sample = PushUpdateResponse(
      successes: ["success_id_1", "success_id_2"],
      failures: [.Mock.sample])

    static var sampleData: Data {
      try! JSONEncoder().encode(sample)
    }
  }
}
#endif
