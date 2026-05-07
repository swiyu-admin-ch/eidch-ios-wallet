public struct PresentationResponseError: Codable, Equatable {

  public let error: String?
  public let errorDescription: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case error
    case errorDescription = "error_description"
  }
}
