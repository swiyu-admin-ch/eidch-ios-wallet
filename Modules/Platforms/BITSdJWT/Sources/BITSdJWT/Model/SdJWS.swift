import BITCore
import BITCrypto
import BITJWT
import Foundation

// MARK: - SdJWS

// https://www.ietf.org/archive/id/draft-ietf-oauth-selective-disclosure-jwt-12.html

open class SdJWS<T: JWT>: JWS<T> {

  // MARK: Lifecycle

  public init(
    jws: JWS<T>,
    payload: T,
    resolvedPayload: [String: Any?],
    rawSdJWS: String,
    disclosableClaims: [SdJWTClaim])
  {
    self.resolvedPayload = payload
    resolvedPayloadDictionary = resolvedPayload
    self.rawSdJWS = rawSdJWS
    self.disclosableClaims = disclosableClaims
    super.init(payload: jws.payload, rawPayload: jws.rawPayload, rawJWS: jws.rawJWS, header: jws.header)
  }

  // MARK: Public

  /// The payload after resolving the digests using the disclosures. This includes all JWT claims (registered, public & private) and disclosable claims.
  public let resolvedPayload: T

  /// The payload as dictionary after resolving the digests using the disclosures. This includes all JWT claims (registered, public & private) and disclosable claims.
  public let resolvedPayloadDictionary: [String: Any?]

  /// The raw string of the SdJWS
  public let rawSdJWS: String

  /// The decoded claims of the disclosures of the SD-JWT
  public let disclosableClaims: [SdJWTClaim]

  public func createSelectiveDisclosure(for keys: [String]) -> String {
    let disclosures = disclosableClaims.filter { keys.contains($0.key) }.map(\.disclosure)
    let rawDisclosures = disclosures.isEmpty ? "" : disclosures.joined(separator: SdJWSDecoder.sdJWTSeparator) + SdJWSDecoder.sdJWTSeparator
    return rawJWS + SdJWSDecoder.sdJWTSeparator + rawDisclosures
  }

}

// MARK: Equatable

extension SdJWS {

  public static func == (lhs: SdJWS, rhs: SdJWS) -> Bool {
    lhs as JWS == rhs as JWS &&
      lhs.resolvedPayload == rhs.resolvedPayload &&
      lhs.resolvedPayloadDictionary.keys == rhs.resolvedPayloadDictionary.keys &&
      lhs.rawSdJWS == rhs.rawSdJWS &&
      lhs.disclosableClaims == rhs.disclosableClaims
  }
}
