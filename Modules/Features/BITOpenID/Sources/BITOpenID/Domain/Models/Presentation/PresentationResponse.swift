import BITCore
import Foundation

// MARK: - PresentationResponse

public struct PresentationResponse: Decodable, Equatable, Hashable, Sendable {

  // MARK: Lifecycle

  public init(redirectUri: URL? = nil) {
    self.redirectUri = redirectUri
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    guard let raw = try? container.decodeIfPresent(String.self, forKey: .redirectUri) else {
      redirectUri = nil
      return
    }

    guard
      let url = URL(string: raw),
      let scheme = url.scheme?.lowercased(),
      !Self.disallowedSchemes.contains(scheme)

    else {
      throw PresentationResponseValidationError.invalidRedirectUri
    }

    redirectUri = url
  }

  // MARK: Public

  public let redirectUri: URL?

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case redirectUri = "redirect_uri"
  }

  private static let disallowedSchemes = [
    "swiyu",
    "swiyu-verify",
    "openid-credential-offer",
    "openid4vp",
    "mdoc",
    "tel",
    "sms",
    "facetime",
    "mailto",
  ]
}

// MARK: - PresentationResponseValidationError

public enum PresentationResponseValidationError: Error, Equatable {
  case invalidRedirectUri
}
