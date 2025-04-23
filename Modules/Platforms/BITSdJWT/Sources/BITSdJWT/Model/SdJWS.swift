import BITCore
import BITCrypto
import BITJWT
import Foundation

// MARK: - SdJWS

/// https://www.ietf.org/archive/id/draft-ietf-oauth-selective-disclosure-jwt-12.html

open class SdJWS<T: Codable & Equatable>: JWSValidatable, Equatable {

  // MARK: Lifecycle

  public init(payload: T, rawPayload: String, header: JWSHeader, raw: String, rawJWS: String, disclosableClaims: [SdJWTClaim]) {
    self.payload = payload
    self.rawPayload = rawPayload
    self.header = header
    self.raw = raw
    self.rawJWS = rawJWS
    self.disclosableClaims = disclosableClaims
  }

  // MARK: Public

  /// The payload after resolving the digests using the disclosures that consists of registered, public and private claims that are known
  public let payload: T

  /// The raw payload json after resolving the digests using the disclosures. This includes all JWT claims (registered, public & private) and disclosable claims.
  public let rawPayload: String

  /// The header of the JWS
  public let header: JWSHeader

  /// The raw string of the SdJWS
  public let raw: String

  /// The raw string of the JWS
  public let rawJWS: String

  /// The decoded claims of the disclosures of the SD-JWT
  public let disclosableClaims: [SdJWTClaim]

  public func createSelectiveDisclosure(for keys: [String]) throws -> String {
    let disclosures = disclosableClaims.filter { keys.contains($0.key) }.map(\.disclosure)
    let rawDisclosures = disclosures.isEmpty ? "" : disclosures.joined(separator: SdJWSDecoder.sdJWTSeparator) + SdJWSDecoder.sdJWTSeparator
    return rawJWS + SdJWSDecoder.sdJWTSeparator + rawDisclosures
  }

}

// MARK: Equatable

extension SdJWS {

  public static func == (lhs: SdJWS, rhs: SdJWS) -> Bool {
    lhs.payload == rhs.payload &&
      lhs.rawPayload == rhs.rawPayload &&
      lhs.header == rhs.header &&
      lhs.rawJWS == rhs.rawJWS &&
      lhs.raw == rhs.raw &&
      lhs.disclosableClaims == rhs.disclosableClaims
  }
}
