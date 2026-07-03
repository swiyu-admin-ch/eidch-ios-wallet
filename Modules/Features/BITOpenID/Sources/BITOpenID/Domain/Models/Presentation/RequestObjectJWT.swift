import BITJWT
import Foundation

public typealias RequestObjectJWS = JWS<RequestObjectJWT>

// MARK: - RequestObjectJWSError

enum RequestObjectJWSError: Error {
  case invalidRawJWT
  case missingIssuer
}

// MARK: - RequestObjectJWT

public class RequestObjectJWT: RequestObject, JWT {

  // MARK: Lifecycle

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    issuer = try container.decodeIfPresent(String.self, forKey: .issuer)
    subject = try container.decodeIfPresent(String.self, forKey: .subject)
    audience = try container.decodeIfPresent(String.self, forKey: .audience)
    expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    activatedAt = try container.decodeIfPresent(Date.self, forKey: .activatedAt)
    issuedAt = try container.decodeIfPresent(Date.self, forKey: .issuedAt)
    jwtIdentifier = try container.decodeIfPresent(String.self, forKey: .jwtIdentifier)

    try super.init(from: decoder)
  }

  // MARK: Public

  public let type: String? = "oauth-authz-req+jwt"
  public let issuer: String?
  public let subject: String?
  public let audience: String?
  public let expiredAt: Date?
  public let activatedAt: Date?
  public let issuedAt: Date?
  public let jwtIdentifier: String?

  public override func isEqual(to other: RequestObject) -> Bool {
    guard super.isEqual(to: other) else { return false }
    let other = other as? RequestObjectJWT
    return
      subject == other?.subject &&
      audience == other?.audience &&
      expiredAt == other?.expiredAt &&
      activatedAt == other?.activatedAt &&
      issuedAt == other?.issuedAt &&
      jwtIdentifier == other?.jwtIdentifier
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case subject = "sub"
    case audience = "aud"
    case expiredAt = "exp"
    case activatedAt = "nbf"
    case issuedAt = "iat"
    case jwtIdentifier = "jti"
  }

}
