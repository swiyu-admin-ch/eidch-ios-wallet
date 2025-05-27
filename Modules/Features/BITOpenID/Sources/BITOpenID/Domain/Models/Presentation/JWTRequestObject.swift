import BITJWT
import Foundation

// MARK: - JWTRequestObjectError

enum JWTRequestObjectError: Error {
  case invalidRawJWT
  case missingIssuer
}

// MARK: - JWTRequestObject

public class JWTRequestObject: RequestObject {

  // MARK: Lifecycle

  init(from jws: JWS<RequestObject>) throws {
    self.jws = jws
    let base = jws.payload

    issuer = try Self.decodeIssuer(jws.rawPayload)

    super.init(
      presentationDefinition: base.presentationDefinition,
      nonce: base.nonce,
      responseUri: base.responseUri,
      clientMetadata: base.clientMetadata,
      responseType: base.responseType,
      clientId: base.clientId,
      clientIdScheme: base.clientIdScheme,
      responseMode: base.responseMode)
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let rawJWT = try container.decode(String.self, forKey: .jwt)
    guard let data = rawJWT.data(using: .utf8) else { throw JWTRequestObjectError.invalidRawJWT }
    jws = try JWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(RequestObject.self, from: data)
    issuer = try container.decode(String.self, forKey: .issuer)

    try super.init(from: decoder)
  }

  // MARK: Public

  public let issuer: String

  // MARK: Internal

  let jws: JWS<RequestObject>

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case jwt
    case issuer
  }

  private static func decodeIssuer(_ jwtPayload: String) throws -> String {
    guard let data = jwtPayload.data(using: .utf8) else { throw JWTRequestObjectError.invalidRawJWT }
    let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    guard let issuer = payload?["iss"] as? String else { throw JWTRequestObjectError.missingIssuer }
    return issuer
  }

}
