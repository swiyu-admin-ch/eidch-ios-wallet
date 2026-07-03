import BITClaimsPathPointer
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
    let (_, jwt, rawDisclosures, keyBinding) = match.output
    guard let jwtData = jwt.data(using: .utf8) else { throw SdJWSDecoderError.invalidRawSdJwt }
    let jws = try jwsDecoder.decode(type, from: jwtData)
    return try decodeSdJwt(jws: jws, disclosures: rawDisclosures.flatMap(String.init), rawSdJWT: rawSdJWT, rawKeyBinding: keyBinding.flatMap(String.init))
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
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol

  private func getKeyIdentifierDid(from jws: JWS<some JWT>) throws -> String {
    try didResolverHelper.getDid(from: jws.header.keyIdentifier)
  }

  private func decodeSdJwt<T: JWT>(jws: JWS<T>, disclosures: String?, rawSdJWT: String, rawKeyBinding: String?) throws -> SdJWS<T> {
    var payloadJSON = try decodePayloadJSON(from: Data(jws.rawPayload.utf8))
    let algorithm = try getDigestAlgorithm(from: payloadJSON)
    payloadJSON.removeValue(forKey: JsonKey.sdAlgorithm.rawValue)
    let disclosureMap = try decodeDisclosures(rawDisclosures: disclosures, algorithm: algorithm)
    var unresolvedDisclosureMap = disclosureMap
    var seenDigests = Set<SdJwtDigest>()
    var disclosures = Set<SdJWTDisclosure>()

    let resolvedJSON = try resolveDigestsWithDisclosures(json: payloadJSON, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: [], disclosures: &disclosures)
    guard unresolvedDisclosureMap.isEmpty else { throw SdJWSDecoderError.digestNotFound }

    return try SdJWS(
      jws: jws,
      payload: decodePayload(T.self, from: resolvedJSON),
      resolvedJSON: resolvedJSON,
      rawSdJWS: rawSdJWT,
      digestAlgorithm: algorithm,
      disclosures: Array(disclosures),
      rawKeyBinding: rawKeyBinding,
      keyIdentifierDid: getKeyIdentifierDid(from: jws))
  }

  private func decodePayloadJSON(from data: Data) throws -> JSON {
    guard
      let payload = try JSONSerialization.jsonObject(with: data) as? JSON
    else { throw SdJWSDecoderError.invalidJWTPayload }
    return payload
  }

  private func getDigestAlgorithm(from payload: JSON) throws -> SdJwtDigestAlgorithm {
    guard let rawAlgorithm = payload[JsonKey.sdAlgorithm.rawValue] else {
      return .sha256
    }
    guard
      let stringAlgorithm = rawAlgorithm as? String,
      let algorithm = SdJwtDigestAlgorithm(rawValue: stringAlgorithm) else
    {
      throw SdJWSDecoderError.unsupportedDigestAlgorithm
    }
    return algorithm
  }

  private func decodeDisclosures(rawDisclosures: String?, algorithm: SdJwtDigestAlgorithm) throws -> [SdJwtDigest: Disclosure] {
    guard let rawDisclosures else { return [:] }
    let disclosures = rawDisclosures.split(separator: Self.sdJWTSeparator)
      .map(String.init)
    return try disclosures
      .compactGroup(keySelector: { disclosure in
        try disclosure.digest(algorithm: algorithm)
      }, valueTransform: { disclosure in
        try decodeDisclosure(from: disclosure)
      }) { _, _ in
        throw SdJWSDecoderError.invalidDisclosure
      }
  }

  private func decodeDisclosure(from disclosure: String) throws -> Disclosure {
    guard
      let decodedDisclosure = disclosure.base64EncodedURLSafe.base64Decoded,
      let array = try decodedDisclosure.toJsonObject() as? [Any]
    else { throw SdJWSDecoderError.invalidDisclosure }
    switch array.count {
    case 3: return try decodeDisclosureWithKey(array, disclosure)
    case 2: return .array(value: array[1], disclosure: disclosure)
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
    return try .keyed(key: key, value: array[2], disclosure: disclosure)
  }

  private func resolveDigestsWithDisclosures(from payload: Any, unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>, path: ClaimsPathPointer, disclosures: inout Set<SdJWTDisclosure>) throws -> Any {
    switch payload {
    case let json as JSON: try resolveDigestsWithDisclosures(json: json, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: path, disclosures: &disclosures)
    case let array as [Any]: try resolveDigestsWithDisclosures(array: array, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: path, disclosures: &disclosures)
    default: payload
    }
  }

  private func resolveDigestsWithDisclosures(json: JSON, unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>, path: ClaimsPathPointer, disclosures: inout Set<SdJWTDisclosure>) throws -> JSON {
    guard
      !json.keys.contains(JsonKey.sdAlgorithm.rawValue),
      !json.keys.contains(JsonKey.arrayDigest.rawValue)
    else { throw SdJWSDecoderError.reservedKeyUsage }
    let resolvedDigests = try json[JsonKey.sd.rawValue].flatMap {
      try resolveDigestArrayWithDisclosures($0, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: path, disclosures: &disclosures)
    } ?? [:]
    let otherElements = json.filter { $0.key != JsonKey.sd.rawValue }
    let resolvedOtherElements: [String: Any] = try otherElements.reduce(into: [:], { dict, element in
      let elementPath = path + [.string(element.key)]
      let resolvedDigest = try resolveDigestsWithDisclosures(from: element.value, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: elementPath, disclosures: &disclosures)
      dict[element.key] = resolvedDigest
    })
    return try resolvedDigests.merging(resolvedOtherElements, uniquingKeysWith: { _, _ in
      throw SdJWSDecoderError.claimAlreadyExists
    })
  }

  private func resolveDigestArrayWithDisclosures(_ digests: Any, unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>, path: ClaimsPathPointer, disclosures: inout Set<SdJWTDisclosure>) throws -> JSON {
    let digests = try decodeDigestArray(digests, seenDigests: &seenDigests)
    let unresolvedDisclosures = digests.compactMap { unresolvedDisclosureMap[$0] } // ignore decoys
    for digest in digests {
      unresolvedDisclosureMap.removeValue(forKey: digest)
    }
    return try unresolvedDisclosures.compactGroup(
      keySelector: { disclosureElement in
        guard case .keyed(let key, _, _) = disclosureElement else { throw SdJWSDecoderError.invalidDisclosure }
        return key
      }, valueTransform: { disclosure in
        guard case .keyed(let key, let value, let disclosure) = disclosure else { throw SdJWSDecoderError.invalidDisclosure }
        let elementPaths = try getPaths(for: value, elementPath: path + [.string(key)])
        disclosures.insert(SdJWTDisclosure(paths: elementPaths, disclosure: disclosure))
        return try resolveDigestsWithDisclosures(from: value, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: path + [.string(key)], disclosures: &disclosures)
      }, uniquingKeysWith: { _, _ -> Any in
        throw SdJWSDecoderError.claimAlreadyExists
      })
  }

  private func decodeDigestArray(_ digests: Any, seenDigests: inout Set<SdJwtDigest>) throws -> [SdJwtDigest] {
    guard let digests = digests as? [SdJwtDigest] else { throw SdJWSDecoderError.invalidDigests }
    guard
      digests.uniqued().count == digests.count,
      seenDigests.intersection(digests).isEmpty
    else {
      throw SdJWSDecoderError.duplicatedDigest
    }
    seenDigests.formUnion(digests)
    return digests
  }

  private func getPaths(for jsonElement: Any, elementPath: ClaimsPathPointer) throws -> [ClaimsPathPointer] {
    var paths = Set<ClaimsPathPointer>()
    if let array = jsonElement as? [Any] {
      paths = try paths.union(getPaths(array: array, path: elementPath))
      paths.insert(elementPath + [.null])
    } else if let dictionary = jsonElement as? [String: Any] {
      paths = try paths.union(getPaths(dictionary: dictionary, path: elementPath))
      paths.insert(elementPath)
    } else {
      paths.insert(elementPath)
    }
    return Array(paths)
  }

  private func getPaths(dictionary: [String: Any], path: ClaimsPathPointer) throws -> Set<ClaimsPathPointer> {
    var paths = Set<ClaimsPathPointer>()
    for (key, value) in dictionary {
      guard key != JsonKey.sd.rawValue else { continue }
      paths = try paths.union(getPaths(for: value, elementPath: path + [.string(key)]))
    }
    return paths
  }

  private func getPaths(array: [Any], path: ClaimsPathPointer) throws -> [ClaimsPathPointer] {
    try array.enumerated().flatMap { index, value in
      if try getArrayDigest(from: value) == nil {
        return try getPaths(for: value, elementPath: path + [.index(index)])
      }
      return []
    }
  }

  private func resolveDigestsWithDisclosures(array: [Any], unresolvedDisclosureMap: inout [SdJwtDigest: Disclosure], seenDigests: inout Set<SdJwtDigest>, path: ClaimsPathPointer, disclosures: inout Set<SdJWTDisclosure>) throws -> [Any] {
    var index = 0
    return try array.compactMap { element in
      let elementPath: ClaimsPathPointer = path + [.index(index)]
      if let digest = try getArrayDigest(from: element) {
        guard !seenDigests.contains(digest) else { throw SdJWSDecoderError.duplicatedDigest }
        seenDigests.insert(digest)
        guard let disclosureElement = unresolvedDisclosureMap[digest] else { return nil } // ignore decoys
        unresolvedDisclosureMap.removeValue(forKey: digest)
        guard case .array(let value, let disclosure) = disclosureElement else { throw SdJWSDecoderError.invalidDisclosure }
        let nestedPaths = try getPaths(for: value, elementPath: elementPath)
        disclosures.insert(SdJWTDisclosure(paths: nestedPaths, disclosure: disclosure))
        index += 1
        return try resolveDigestsWithDisclosures(from: value, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: elementPath, disclosures: &disclosures)
      }
      index += 1
      return try resolveDigestsWithDisclosures(from: element, unresolvedDisclosureMap: &unresolvedDisclosureMap, seenDigests: &seenDigests, path: elementPath, disclosures: &disclosures)
    }
  }

  private func getArrayDigest(from element: Any) throws -> String? {
    guard
      let dictionary = element as? JSON,
      dictionary.keys.map({ $0 }) == [JsonKey.arrayDigest.rawValue]
    else { return nil }
    guard let digest = dictionary[JsonKey.arrayDigest.rawValue] as? SdJwtDigest else {
      throw SdJWSDecoderError.invalidDigests
    }
    return digest
  }

  private func decodePayload<T: Decodable>(_ type: T.Type, from resolvedPayload: JSON) throws -> T {
    let decoder = JSONDecoder(dateDecodingStrategy: dateDecodingStrategy)
    let payloadData = try JSONSerialization.data(withJSONObject: resolvedPayload)
    return try decoder.decode(T.self, from: payloadData)
  }
}

// MARK: SdJWSDecoder.Disclosure

extension SdJWSDecoder {
  private enum Disclosure {
    case keyed(key: String, value: Any, disclosure: String)
    case array(value: Any, disclosure: String)
  }
}
