import Foundation

// MARK: - PresentationErrorRequestBody

public struct PresentationErrorRequestBody: Codable {

  // MARK: Lifecycle

  public init(error: Code, errorDescription: String? = nil) {
    self.error = error
    self.errorDescription = errorDescription
  }

  // MARK: Public

  public enum Code: String, Codable, Equatable {
    case invalidRequest = "invalid_request"
    case invalidClient = "invalid_client"
    case accessDenied = "access_denied"
  }

  public let error: Code
  public let errorDescription: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case error
    case errorDescription = "error_description"
  }
}
