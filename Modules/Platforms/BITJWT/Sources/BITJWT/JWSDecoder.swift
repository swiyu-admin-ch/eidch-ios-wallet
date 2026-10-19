import Foundation
import JWSETKit

// MARK: - JWSDecoderProtocol

public protocol JWSDecoderProtocol: Sendable {
  func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> JWS<T>
}

// MARK: - JWSDecoderError

public enum JWSDecoderError: Error {
  case invalidType
  case invalidPayload
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
    let header = try JWSHeader(from: jws)

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
}
