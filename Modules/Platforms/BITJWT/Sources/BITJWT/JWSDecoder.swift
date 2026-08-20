import BITCrypto
import Foundation
import JWSETKit

// MARK: - JWSDecoderProtocol

public protocol JWSDecoderProtocol {
  func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> JWS<T>
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

  public func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> JWS<T> {
    let jws = try JSONWebSignaturePlain(from: data)
    let payload: T = try decodePayload(from: jws.payload.encoded)
    let rawPayload = try decodeRawPayload(from: jws.payload.encoded)
    let header = try createHeader(from: jws)

    #warning("To be deleted when contraction on dc+sd-jwt happens")
    if let acceptedTypes = payload.acceptedTypes {
      guard let headerType = header.type, acceptedTypes.contains(headerType) else {
        throw JWSDecoderError.invalidType
      }
    }
    return try JWS(
      payload: payload,
      rawPayload: rawPayload,
      rawJWS: String(jws),
      header: header)
  }

  // MARK: Private

  private func decodePayload<T: Decodable>(from data: Data) throws -> T {
    let decoder = JSONDecoder(dateDecodingStrategy: dateDecodingStrategy)
    return try decoder.decode(T.self, from: data)
  }

  private func decodeRawPayload(from data: Data) throws -> String {
    guard let rawPayload = String(data: data, encoding: .utf8) else {
      throw JWSDecoderError.invalidPayload
    }
    return rawPayload
  }

  private func createHeader(from jws: JSONWebSignaturePlain) throws -> JWSHeader {
    guard
      let algorithm = jws.header.algorithm,
      let jwtAlgorithm = JWTAlgorithm(rawValue: algorithm.rawValue)
    else { throw JWSDecoderError.algorithmNotFound }

    return try JWSHeader(
      algorithm: jwtAlgorithm,
      type: jws.header.type?.rawValue,
      keyIdentifier: jws.header.keyId,
      jwk: jws.header.publicJwk(),
      profileVersion: jws.profileVersion)
  }
}

extension JOSEHeader {
  fileprivate func publicJwk() throws -> BITCrypto.JWK? {
    // swiftformat:disable:next redundantOptionalBinding redundantSelf
    guard let key = self.key else {
      return nil
    }
    let data = try JSONEncoder().encode(AnyJSONWebKey(key))
    return try JSONDecoder().decode(BITCrypto.JWK.self, from: data)
  }
}

extension JSONWebSignaturePlain {
  fileprivate var profileVersion: String? {
    header["profile_version"]
  }
}
