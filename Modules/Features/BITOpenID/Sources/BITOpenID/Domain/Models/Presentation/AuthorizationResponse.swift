import Foundation

// MARK: - AuthorizationResponse

/// https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-response
public struct AuthorizationResponse: Equatable {

  // MARK: Lifecycle

  public init(vpToken: [String: [String]], responseMode: RequestObject.ResponseMode? = nil, state: String? = nil) {
    self.vpToken = vpToken
    self.state = state
    self.responseMode = responseMode
  }

  // MARK: Public

  public func asDictionary() -> [String: Any] {
    do {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase

      var dictionary = [String: Any]()

      // dc_api/dc_api.jwt responses aren't JWE-encrypted at the OID4VP level: the proximity
      // transport (BLE) they're used over already provides end-to-end encryption, so the vp_token
      // is returned as a plain object rather than being stringified into a JWE payload.
      if responseMode?.isDigitalCredentialsApi == true {
        dictionary["vp_token"] = vpToken
        return dictionary
      }

      guard let vpTokenString = try String(data: encoder.encode(vpToken), encoding: .utf8) else {
        return dictionary
      }
      dictionary["vp_token"] = vpTokenString
      if let state {
        dictionary["state"] = state
      }
      return dictionary

    } catch {
      return [:]
    }
  }

  // MARK: Internal

  let vpToken: [String: [String]]
  let state: String?

  // MARK: Private

  private let responseMode: RequestObject.ResponseMode?
}
