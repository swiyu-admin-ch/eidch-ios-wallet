import BITCrypto
import Foundation
import JOSESwift

// MARK: - JWSDecoderProtocol

public protocol JWSDecoderProtocol {
  func decode<T>(_ type: T.Type, from data: Data) throws -> JWS<T> where T: JWTPayload & Decodable
}

// MARK: - JWSDecoderError

public enum JWSDecoderError: Error {
  case invalidType
  case invalidPayload
  case algorithmNotFound
}

// MARK: - JWSDecoder

public struct JWSDecoder: JWSDecoderProtocol {

  // MARK: Lifecycle

  public init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970) {
    self.dateDecodingStrategy = dateDecodingStrategy
  }

  // MARK: Public

  public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy

  public func decode<T>(_ type: T.Type, from data: Data) throws -> JWS<T> where T: JWTPayload & Decodable {
    let jws = try JOSESwift.JWS(compactSerialization: data)
    let payload: T = try decodePayload(from: jws.payload.data())
    let rawPayload = try decodeRawPayload(from: jws.payload.data())
    let header = try createHeader(from: jws)
    if let type = payload.type, header.type != type { throw JWSDecoderError.invalidType }
    return JWS(
      payload: payload,
      rawPayload: rawPayload,
      rawJWS: jws.compactSerializedString,
      header: header)
  }

  // MARK: Private

  private func decodePayload<T>(from data: Data) throws -> T where T: Decodable {
    let decoder = JSONDecoder(dateDecodingStrategy: dateDecodingStrategy)
    return try decoder.decode(T.self, from: data)
  }

  private func decodeRawPayload(from data: Data) throws -> String {
    guard let rawPayload = String(data: data, encoding: .utf8) else {
      throw JWSDecoderError.invalidPayload
    }
    return rawPayload
  }

  private func createHeader(from jws: JOSESwift.JWS) throws -> JWSHeader {
    guard
      let algorithm = jws.header.algorithm,
      let jwtAlgorithm = JWTAlgorithm(rawValue: algorithm.rawValue)
    else { throw JWSDecoderError.algorithmNotFound }
    return try JWSHeader(
      algorithm: jwtAlgorithm,
      type: jws.header.typ,
      keyIdentifier: jws.header.kid,
      jwk: jws.header.publicJwk())
  }
}

extension JOSESwift.JWSHeader {
  fileprivate func publicJwk() throws -> BITCrypto.JWK? {
    if let jwkData = jwkTyped?.jsonData() {
      try JSONDecoder().decode(BITCrypto.JWK.self, from: jwkData)
    } else {
      nil
    }
  }
}
