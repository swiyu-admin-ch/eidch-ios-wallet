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
    resolvedJSON: JSON,
    rawSdJWS: String,
    disclosureMap: [String: Disclosure],
    disclosableClaims: [SdJWTClaim])
  {
    resolvedPayload = payload
    self.resolvedJSON = resolvedJSON
    self.rawSdJWS = rawSdJWS
    self.disclosureMap = disclosureMap
    self.disclosableClaims = disclosableClaims
    super.init(payload: jws.payload, rawPayload: jws.rawPayload, rawJWS: jws.rawJWS, header: jws.header)
  }

  // MARK: Public

  /// The payload after resolving the digests using the disclosures. This includes all JWT claims (registered, public & private) and disclosable claims.
  public let resolvedPayload: T

  /// The payload as JSON after resolving the digests using the disclosures. This includes all JWT claims (registered, public & private) and disclosable claims.
  public let resolvedJSON: JSON

  /// The raw string of the SdJWS
  public let rawSdJWS: String

  /// The disclosures of the SD-JWT by digest
  public let disclosureMap: [String: Disclosure]

  /// The decoded claims of the disclosures of the SD-JWT
  public let disclosableClaims: [SdJWTClaim]

  public func createSelectiveDisclosure(for keys: [String]) -> String {
    let disclosures: [String] = disclosureMap.compactMap { _, disclosure in
      guard
        case .keyedElement(let key, _, let disclosure) = disclosure,
        keys.contains(key)
      else {
        #warning("TODO: handle array elements (EIDNUCLEUS-759)")
        return nil
      }
      return disclosure
    }
    let rawDisclosures = disclosures.isEmpty ? "" : disclosures.joined(separator: SdJWSDecoder.sdJWTSeparator) + SdJWSDecoder.sdJWTSeparator
    return rawJWS + SdJWSDecoder.sdJWTSeparator + rawDisclosures
  }

}

// MARK: Equatable

extension SdJWS {

  public static func == (lhs: SdJWS, rhs: SdJWS) -> Bool {
    lhs as JWS == rhs as JWS &&
      lhs.resolvedPayload == rhs.resolvedPayload &&
      lhs.resolvedJSON.keys == rhs.resolvedJSON.keys &&
      lhs.rawSdJWS == rhs.rawSdJWS &&
      lhs.disclosureMap.keys == rhs.disclosureMap.keys &&
      lhs.disclosableClaims == rhs.disclosableClaims
  }
}
