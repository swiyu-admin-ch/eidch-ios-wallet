import BITClaimsPathPointer
import BITCore
import BITCrypto
import BITJWT
import Factory
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
    digestAlgorithm: SdJwtDigestAlgorithm = .sha256,
    disclosures: [SdJWTDisclosure],
    rawKeyBinding: String?,
    keyIdentifierDid: String)
  {
    resolvedPayload = payload
    self.resolvedJSON = resolvedJSON
    self.rawSdJWS = rawSdJWS
    self.digestAlgorithm = digestAlgorithm
    self.disclosures = disclosures
    self.rawKeyBinding = rawKeyBinding
    self.keyIdentifierDid = keyIdentifierDid
    super.init(payload: jws.payload, rawPayload: jws.rawPayload, rawJWS: jws.rawJWS, header: jws.header)
  }

  // MARK: Public

  /// The payload after resolving the digests using the disclosures. This includes all JWT claims (registered, public & private) and disclosable claims.
  public let resolvedPayload: T

  /// The payload as JSON after resolving the digests using the disclosures. This includes all JWT claims (registered, public & private) and disclosable claims.
  public let resolvedJSON: JSON

  /// The raw string of the SdJWS
  public let rawSdJWS: String

  /// The digest algorithm declared by `_sd_alg`, or sha-256 not explicitly declared
  public let digestAlgorithm: SdJwtDigestAlgorithm

  /// The decoded disclosures of the SD-JWT
  public let disclosures: [SdJWTDisclosure]
  public let rawKeyBinding: String?

  /// The resolved DID from the `kid` claim of the JWS
  public let keyIdentifierDid: String

  public func createSelectiveDisclosure(for paths: [ClaimsPathPointer]) -> String {
    let disclosures = findDisclosures(for: paths)
    let rawDisclosures = disclosures.map(\.disclosure).joined(separator: SdJWSDecoder.sdJWTSeparator)
    let sdJws = rawJWS + SdJWSDecoder.sdJWTSeparator + rawDisclosures + (rawDisclosures.isEmpty ? "" : SdJWSDecoder.sdJWTSeparator)
    if let rawKeyBinding {
      return sdJws + rawKeyBinding
    }
    return sdJws
  }

  public func getPresentingPaths(for paths: [ClaimsPathPointer]) -> [ClaimsPathPointer] {
    let disclosures = findDisclosures(for: paths)
    return Array(Set(disclosures.flatMap(\.paths)))
  }

  // MARK: Private

  private func findDisclosures(for paths: [ClaimsPathPointer]) -> Set<SdJWTDisclosure> {
    var result = Set<SdJWTDisclosure>()
    for disclosure in disclosures {
      let isRequested = paths.contains(where: { path in
        disclosure.paths.contains(where: { path.pointsAtSetOf($0) })
      })
      if isRequested {
        result.insert(disclosure)
        let parentDisclosures = findParentDisclosures(for: disclosure.paths.first ?? [])
        result = result.union(parentDisclosures)
      }
    }
    return result
  }

  private func findParentDisclosures(for path: ClaimsPathPointer) -> Set<SdJWTDisclosure> {
    var result = Set<SdJWTDisclosure>()
    var currentPath = path
    while currentPath.last != nil {
      let parentPath = currentPath.parentPath
      let parentDisclosure = disclosures.first { $0.paths.contains(parentPath) }
      if let parentDisclosure {
        result.insert(parentDisclosure)
      }
      currentPath = currentPath.dropLast()
    }
    return result
  }
}

extension ClaimsPathPointer {
  var parentPath: ClaimsPathPointer {
    if case .index = last {
      dropLast() + [.null]
    } else {
      dropLast()
    }
  }
}

// MARK: Equatable

extension SdJWS {

  public static func == (lhs: SdJWS, rhs: SdJWS) -> Bool {
    lhs as JWS == rhs as JWS &&
      lhs.resolvedPayload == rhs.resolvedPayload &&
      lhs.resolvedJSON.keys == rhs.resolvedJSON.keys &&
      lhs.rawSdJWS == rhs.rawSdJWS &&
      lhs.digestAlgorithm == rhs.digestAlgorithm &&
      lhs.disclosures == rhs.disclosures &&
      lhs.rawKeyBinding == rhs.rawKeyBinding
  }
}
