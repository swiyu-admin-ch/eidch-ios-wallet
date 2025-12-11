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
}

// MARK: - SdJWSDecoderProtocol

public protocol SdJWSDecoderProtocol {
  func decode<T>(_ type: T.Type, from data: Data) throws -> SdJWS<T> where T: JWTPayload & Decodable
}

// MARK: - SdJWSDecoder

public struct SdJWSDecoder: SdJWSDecoderProtocol {

  // MARK: Lifecycle

  public init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970, strictPayloadDecoding: Bool = false) {
    self.dateDecodingStrategy = dateDecodingStrategy
    self.strictPayloadDecoding = strictPayloadDecoding
  }

  // MARK: Public

  public static let reservedClaimNames: Set<String> = [
    "iss", "sub", "aud", "exp", "iat", "nbf", "jti", // JWT
    "_sd_alg", "_sd", // SD-JWT
    "cnf", "vct", "status", "vct#integrity", "vct_metadata_uri", "vct_metadata_uri#integrity", // VcSdJwt
  ]

  public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
  public var strictPayloadDecoding: Bool

  public func decode<T>(_ type: T.Type, from data: Data) throws -> SdJWS<T> where T: JWTPayload & Decodable {
    guard
      let rawSdJWT = String(data: data, encoding: .utf8),
      let match = try Self.sdJWTPattern.wholeMatch(in: rawSdJWT)
    else { throw SdJWSDecoderError.invalidRawSdJwt }
    let (_, jwt, rawDisclosures, _) = match.output
    guard let jwtData = jwt.data(using: .utf8) else { throw SdJWSDecoderError.invalidRawSdJwt }
    if let disclosures = rawDisclosures {
      return try decodeSdJwt(jwtData, disclosures: String(disclosures), rawSdJWT: rawSdJWT)
    }
    return try decodeUndisclosedSdJwt(jwtData, rawSdJWT: rawSdJWT)
  }

  // MARK: Internal

  static let sdJWTSeparator = "~"

  // MARK: Private

  private enum JsonKey: String {
    case sd = "_sd"
    case sdAlgorithm = "_sd_alg"
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

  private func decodeSdJwt<T>(_ jwtData: Data, disclosures: String, rawSdJWT: String) throws -> SdJWS<T> where T: JWTPayload & Decodable {
    let jws: JWS<T> = try jwsDecoder.decode(T.self, from: jwtData)
    guard
      let jwtPayloadData = jws.rawPayload.data(using: .utf8),
      let payloadJson = try JSONSerialization.jsonObject(with: jwtPayloadData) as? [String: Any?]
    else { throw SdJWSDecoderError.invalidJWTPayload }
    if strictPayloadDecoding {
      guard payloadJson.keys.allSatisfy({ Self.reservedClaimNames.contains($0) }) else { throw SdJWSDecoderError.invalidJWTPayload }
    }

    let claims = try decodeClaims(from: payloadJson, rawDisclosures: String(disclosures))
    let resolvedPayload = try resolvePayload(from: payloadJson, claims: claims)
    let decoder = JSONDecoder(dateDecodingStrategy: dateDecodingStrategy)
    let payloadData = try JSONSerialization.data(withJSONObject: resolvedPayload)
    let payload = try decoder.decode(T.self, from: payloadData)
    return SdJWS(
      jws: jws,
      payload: payload,
      resolvedPayload: resolvedPayload,
      rawSdJWS: rawSdJWT,
      disclosableClaims: claims)
  }

  private func decodeClaims(from payload: [String: Any?], rawDisclosures: String) throws -> [SdJWTClaim] {
    let algorithm = try findAlgorithm(in: payload)
    guard let digests = payload[JsonKey.sd.rawValue] as? [SdJwtDigest], digests.areUnique else {
      throw SdJWSDecoderError.invalidDigests
    }
    return try rawDisclosures.split(separator: Self.sdJWTSeparator)
      .map(String.init)
      .compactMap { disclosure -> SdJWTClaim in
        try decodeClaim(from: disclosure, digests: digests, algorithm: algorithm)
      }
  }

  private func findAlgorithm(in payload: [String: Any?], defaultAlgorithm: StringDigest.Algorithm = .sha256) throws -> StringDigest.Algorithm {
    guard
      let stringAlgorithm = payload[JsonKey.sdAlgorithm.rawValue] as? String
    else { return defaultAlgorithm }
    guard let algorithm = StringDigest.Algorithm(rawValue: stringAlgorithm) else {
      throw SdJWSDecoderError.unsupportedDigestAlgorithm
    }
    return algorithm
  }

  private func decodeClaim(from disclosure: String, digests: [SdJwtDigest], algorithm: StringDigest.Algorithm) throws -> SdJWTClaim {
    guard
      // sd-jwt disclosures are formatted URL unsafe
      let rawDisclosableClaim = disclosure.base64EncodedURLSafe.base64Decoded,
      let disclosableClaim = try rawDisclosableClaim.toJsonObject() as? [Any],
      disclosableClaim.count == 3,
      let key = disclosableClaim[1] as? String
    else { throw SdJWSDecoderError.invalidDisclosure }

    let actualDigest = try disclosure.digest(algorithm: algorithm)
    guard let digest = digests.first(where: { $0 == actualDigest }) else {
      throw SdJWSDecoderError.digestNotFound
    }
    return try SdJWTClaim(
      key: key,
      value: disclosableClaim[2],
      disclosure: disclosure,
      digest: digest)
  }

  /// Resolve payload by replacing digests with actual claim value. Only supports flat hierarchy so far (for more info see: https://www.ietf.org/archive/id/draft-ietf-oauth-selective-disclosure-jwt-12.html#name-example-flat-sd-jwt)
  private func resolvePayload(from payload: [String: Any?], claims: [SdJWTClaim]) throws -> [String: Any?] {
    var resolvedPayload = payload
    for claim in claims {
      guard resolvedPayload[claim.key] == nil else {
        throw SdJWSDecoderError.claimAlreadyExists
      }
      resolvedPayload.updateValue(claim.value?.convertToAny(), forKey: claim.key)
    }
    resolvedPayload.removeValue(forKey: JsonKey.sd.rawValue)
    resolvedPayload.removeValue(forKey: JsonKey.sdAlgorithm.rawValue)

    return resolvedPayload
  }

  private func decodeUndisclosedSdJwt<T>(_ data: Data, rawSdJWT: String) throws -> SdJWS<T> where T: JWTPayload & Decodable {
    let jws = try jwsDecoder.decode(T.self, from: data)
    guard
      let payloadData = jws.rawPayload.data(using: .utf8),
      let payload = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any]
    else { throw SdJWSDecoderError.invalidJWTPayload }
    return SdJWS(
      jws: jws,
      payload: jws.payload,
      resolvedPayload: payload,
      rawSdJWS: rawSdJWT,
      disclosableClaims: [])
  }
}

extension Array where Element: Hashable {
  var areUnique: Bool {
    var uniques = Set<Element>()
    return allSatisfy { uniques.insert($0).inserted }
  }
}
