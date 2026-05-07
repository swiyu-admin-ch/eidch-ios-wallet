import BITCore
import BITJWT
import Factory
import Foundation
import RegexBuilder

// MARK: - SdJWSDecoderError

enum SdJWSDecoderError: Error, Equatable {
  case invalidRawSdJwt
  case invalidJWTPayload
  case unsupportedDigestAlgorithm
  case invalidDigests
  case digestNotFound
  case invalidDisclosure
  case claimAlreadyExists
  case invalidSdClaim(String)
  case reservedKeyUsage
  case duplicatedDigest
}

// MARK: - SdJWSDecoderProtocol

public protocol SdJWSDecoderProtocol {
  func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> SdJWS<T>
}

// MARK: - SdJWSDecoder

public struct SdJWSDecoder: SdJWSDecoderProtocol {

  // MARK: Lifecycle

  public init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970, nonSelectivelyDisclosableClaims: [String] = []) {
    self.dateDecodingStrategy = dateDecodingStrategy
    self.nonSelectivelyDisclosableClaims = nonSelectivelyDisclosableClaims
  }

  // MARK: Public

  public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
  public var nonSelectivelyDisclosableClaims: [String]

  public func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> SdJWS<T> {
    guard
      let rawSdJWT = String(data: data, encoding: .utf8),
      let match = try Self.sdJWTPattern.wholeMatch(in: rawSdJWT)
    else { throw SdJWSDecoderError.invalidRawSdJwt }
    let (_, jwt, rawDisclosures, _) = match.output
    guard let jwtData = jwt.data(using: .utf8) else { throw SdJWSDecoderError.invalidRawSdJwt }
    let jws = try jwsDecoder.decode(type, from: jwtData)
    return try decodeSdJwt(jws: jws, disclosures: rawDisclosures.flatMap(String.init), rawSdJWT: rawSdJWT)
  }

  // MARK: Internal

  static let sdJWTSeparator = "~"

  // MARK: Private

  private enum JsonKey: String, CaseIterable {
    case sd = "_sd"
    case sdAlgorithm = "_sd_alg"
    case arrayDigest = "..."
  }

  private static let jwtCharacters = OneOrMore {
    ChoiceOf {
      .word
      "-"
    }
  }

  private static let jwtCapture = Capture {
    jwtCharacters
    "."
    jwtCharacters
    "."
    jwtCharacters
  }

  private static let disclosuresCapture = Capture {
    OneOrMore {
      jwtCharacters
      sdJWTSeparator
    }
  }

  private static let sdJWTPattern = Regex {
    jwtCapture
    sdJWTSeparator
    Optionally {
      disclosuresCapture
    }
    Optionally {
      jwtCapture
    }
  }

  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol

  private func decodeSdJwt<T: JWT>(jws: JWS<T>, disclosures: String?, rawSdJWT: String) throws -> SdJWS<T> {
    var payloadJSON = try decodePayloadJSON(from: Data(jws.rawPayload.utf8))
    let algorithm = try getDigestAlgorithm(from: payloadJSON)
    payloadJSON.removeValue(forKey: JsonKey.sdAlgorithm.rawValue)
    let disclosureMap = try decodeDisclosures(rawDisclosures: disclosures, algorithm: algorithm)
    var unresolvedDisclosureMap = disclosureMap
    var seenDigests = Set<SdJwtDigest>()

    let resolvedJSON = try resolveDigestsWithDisclosures(json: payloadJSON, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
    guard unresolvedDisclosureMap.isEmpty else { throw SdJWSDecoderError.digestNotFound }

    return try SdJWS(
      jws: jws,
      payload: decodePayload(T.self, from: resolvedJSON),
      resolvedJSON: resolvedJSON,
      rawSdJWS: rawSdJWT,
      disclosureMap: disclosureMap,
      disclosableClaims: decodeClaims(from: jws, rawDisclosures: disclosures))
  }

  private func decodePayloadJSON(from data: Data) throws -> JSON {
    guard
      let payload = try JSONSerialization.jsonObject(with: data) as? JSON
    else { throw SdJWSDecoderError.invalidJWTPayload }
    return payload
  }

  private func getDigestAlgorithm(from payload: JSON) throws -> StringDigest.Algorithm {
    guard
      let stringAlgorithm = payload[JsonKey.sdAlgorithm.rawValue] as? String
    else { return .sha256 }
    guard let algorithm = StringDigest.Algorithm(rawValue: stringAlgorithm) else {
      throw SdJWSDecoderError.unsupportedDigestAlgorithm
    }
    return algorithm
  }

  private func decodeDisclosures(rawDisclosures: String?, algorithm: StringDigest.Algorithm) throws -> [SdJwtDigest: Disclosure] {
    guard let rawDisclosures else { return [:] }
    let disclosures = rawDisclosures.split(separator: Self.sdJWTSeparator)
      .map(String.init)
    return try disclosures
      .compactGroup(keySelector: { disclosure in
        try disclosure.digest(algorithm: algorithm)
      }, valueTransform: { disclosure in
        try decodeDisclosure(from: disclosure, algorithm: algorithm)
      }) { _, _ in
        throw SdJWSDecoderError.invalidDisclosure
      }
  }

  private func decodeDisclosure(from disclosure: String, algorithm: StringDigest.Algorithm) throws -> Disclosure {
    guard
      let decodedDisclosure = disclosure.base64EncodedURLSafe.base64Decoded,
      let array = try decodedDisclosure.toJsonObject() as? [Any]
    else { throw SdJWSDecoderError.invalidDisclosure }
    switch array.count {
    case 3: return try decodeDisclosureWithKey(array, disclosure)
    case 2: return Disclosure.arrayElement(value: array[1], disclosure: disclosure)
    default: throw SdJWSDecoderError.invalidDisclosure
    }
  }

  private func decodeDisclosureWithKey(_ array: [Any], _ disclosure: String) throws -> Disclosure {
    guard
      let key = array[1] as? String,
      !JsonKey.allCases.map(\.rawValue).contains(key),
      !nonSelectivelyDisclosableClaims.contains(key)
    else {
      throw SdJWSDecoderError.invalidSdClaim(disclosure)
    }
    return try Disclosure.keyedElement(key: key, value: array[2], disclosure: disclosure)
  }

  private func resolveDigestsWithDisclosures(from payload: Any, unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>) throws -> Any {
    switch payload {
    case let json as JSON: try resolveDigestsWithDisclosures(json: json, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
    case let array as [Any]: try resolveDigestsWithDisclosures(array: array, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
    default: payload
    }
  }

  private func resolveDigestsWithDisclosures(json: JSON, unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>) throws -> JSON {
    guard
      !json.keys.contains(JsonKey.sdAlgorithm.rawValue),
      !json.keys.contains(JsonKey.arrayDigest.rawValue)
    else { throw SdJWSDecoderError.reservedKeyUsage }
    let resolvedDigests = try json[JsonKey.sd.rawValue].flatMap {
      try resolveDigestArrayWithDisclosures($0, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
    } ?? [:]
    let otherElements = json.filter { $0.key != JsonKey.sd.rawValue }
    let resolvedOtherElements = try otherElements.mapValues { element in
      try resolveDigestsWithDisclosures(from: element, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
    }
    return try resolvedDigests.merging(resolvedOtherElements, uniquingKeysWith: { _, _ in
      throw SdJWSDecoderError.claimAlreadyExists
    })
  }

  private func resolveDigestArrayWithDisclosures(_ digests: Any, unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>) throws -> JSON {
    let digests = try decodeDigestArray(digests, seenDigests: &seenDigests)
    let disclosures = digests.compactMap { unresolvedDisclosureMap[$0] } // ignore decoys
    for digest in digests {
      unresolvedDisclosureMap.removeValue(forKey: digest)
    }
    return try disclosures.compactGroup(
      keySelector: { disclosure in
        guard case .keyedElement(let key, _, _) = disclosure else { throw SdJWSDecoderError.invalidDisclosure }
        return key
      }, valueTransform: { disclosure in
        guard case .keyedElement(_, let value, _) = disclosure else { throw SdJWSDecoderError.invalidDisclosure }
        return try resolveDigestsWithDisclosures(from: value, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
      }, uniquingKeysWith: { _, _ -> Any in
        throw SdJWSDecoderError.claimAlreadyExists
      })
  }

  private func decodeDigestArray(_ digests: Any, seenDigests: inout Set<SdJwtDigest>) throws -> [SdJwtDigest] {
    guard let digests = digests as? [SdJwtDigest] else { throw SdJWSDecoderError.invalidDigests }
    guard
      digests.areUnique,
      seenDigests.intersection(digests).isEmpty
    else {
      throw SdJWSDecoderError.duplicatedDigest
    }
    seenDigests.formUnion(digests)
    return digests
  }

  private func resolveDigestsWithDisclosures(array: [Any], unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>) throws -> [Any] {
    try array.compactMap { element in
      if
        let dictionary = element as? JSON,
        dictionary.keys.map({ $0 }) == [JsonKey.arrayDigest.rawValue]
      {
        guard let digest = dictionary[JsonKey.arrayDigest.rawValue] as? SdJwtDigest else {
          throw SdJWSDecoderError.invalidDigests
        }
        guard !seenDigests.contains(digest) else { throw SdJWSDecoderError.duplicatedDigest }
        seenDigests.insert(digest)
        guard let disclosure = unresolvedDisclosureMap[digest] else { return nil } // ignore decoys
        unresolvedDisclosureMap.removeValue(forKey: digest)
        guard case .arrayElement(let value, _) = disclosure else { throw SdJWSDecoderError.invalidDisclosure }
        return try resolveDigestsWithDisclosures(from: value, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
      }
      return try resolveDigestsWithDisclosures(from: element, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests)
    }
  }

  private func decodePayload<T: Decodable>(_ type: T.Type, from resolvedPayload: JSON) throws -> T {
    let decoder = JSONDecoder(dateDecodingStrategy: dateDecodingStrategy)
    let payloadData = try JSONSerialization.data(withJSONObject: resolvedPayload)
    return try decoder.decode(T.self, from: payloadData)
  }
}

extension Array where Element: Hashable {
  var areUnique: Bool {
    var uniques = Set<Element>()
    return allSatisfy { uniques.insert($0).inserted }
  }
}

#warning("TODO: will be deleted in EIDNUCLEUS-752")
extension SdJWSDecoder {
  private func decodeClaims(from jws: JWS<some JWT>, rawDisclosures: String?) throws -> [SdJWTClaim] {
    guard
      let jwtPayloadData = jws.rawPayload.data(using: .utf8),
      let payloadJson = try JSONSerialization.jsonObject(with: jwtPayloadData) as? JSON
    else { throw SdJWSDecoderError.invalidJWTPayload }
    let algorithm = try getDigestAlgorithm(from: payloadJson)
    guard payloadJson.keys.contains(JsonKey.sd.rawValue) else { return [] }
    guard let digests = payloadJson[JsonKey.sd.rawValue] as? [SdJwtDigest], digests.areUnique else {
      throw SdJWSDecoderError.invalidDigests
    }
    return try rawDisclosures?.split(separator: Self.sdJWTSeparator)
      .map(String.init)
      .compactMap { disclosure in
        try decodeClaim(from: disclosure, digests: digests, algorithm: algorithm)
      } ?? []
  }

  private func decodeClaim(from disclosure: String, digests: [SdJwtDigest], algorithm: StringDigest.Algorithm) throws -> SdJWTClaim? {
    guard
      // sd-jwt disclosures are formatted URL unsafe
      let rawDisclosableClaim = disclosure.base64EncodedURLSafe.base64Decoded,
      let disclosableClaim = try rawDisclosableClaim.toJsonObject() as? [Any]
    else { throw SdJWSDecoderError.invalidDisclosure }
    if disclosableClaim.count == 2 { return nil } // arrays not supported here
    guard
      disclosableClaim.count == 3,
      let key = disclosableClaim[1] as? String
    else { throw SdJWSDecoderError.invalidDisclosure }

    let actualDigest = try disclosure.digest(algorithm: algorithm)
    guard let digest = digests.first(where: { $0 == actualDigest }) else {
      return nil // normally failed but due to support of recursive we just ignore digest
    }
    return try SdJWTClaim(
      key: key,
      path: [.string(key)],
      value: disclosableClaim[2],
      disclosure: disclosure,
      digest: digest)
  }
}
