import BITCrypto
import BITVault
import Foundation
import JWSETKit

// MARK: - JWSEncoderProtocol

public protocol JWSEncoderProtocol {
  func encode(_ value: some JWT, using keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> Data
  func encode<T: JWT>(_ value: T, keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> JWS<T>
}

extension JWSEncoderProtocol {
  public func encode(_ value: some JWT, using keyPair: VaultKeyPair) throws -> Data {
    try encode(value, using: keyPair, additionalHeaderParameters: [:])
  }

  public func encode<T: JWT>(_ value: T, keyPair: VaultKeyPair) throws -> JWS<T> {
    try encode(value, keyPair: keyPair, additionalHeaderParameters: [:])
  }
}

// MARK: - JWSEncoderError

public enum JWSEncoderError: Error {
  case algorithmNotFound
  case wrongKeyType
  case cannotCreateJwk
  case invalidEncoding
}

// MARK: - JWSEncoder

public struct JWSEncoder: JWSEncoderProtocol {

  // MARK: Lifecycle

  public init(keyEncodingStrategy: KeyEncodingStrategy = .jwk, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .secondsSince1970) {
    self.keyEncodingStrategy = keyEncodingStrategy
    self.dateEncodingStrategy = dateEncodingStrategy
  }

  // MARK: Public

  public enum KeyEncodingStrategy {
    case jwk
    case none
  }

  public var keyEncodingStrategy: KeyEncodingStrategy
  public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy

  public func encode(_ jwt: some JWT, using keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> Data {
    let algorithm = try parseAlgorithm(keyPair.algorithm.rawValue)
    let header = try header(using: keyPair, algorithm: algorithm, type: jwt.type, additionalParameters: additionalHeaderParameters)
    let payload = try createPayloadData(jwt)
    var jws = try JSONWebSignaturePlain(
      signatures: [JSONWebSignatureHeader(protected: header, signature: Data())],
      payload: ProtectedDataWebContainer(encoded: payload))
    try jws.updateSignature(using: keyPair.privateKey)
    return try Data(compact: jws)
  }

  public func encode<T: JWT>(_ value: T, keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> JWS<T> {
    let data = try encode(value, using: keyPair, additionalHeaderParameters: additionalHeaderParameters)

    guard
      let rawJWS = String(data: data, encoding: .utf8),
      let rawPayload = try? createPayloadData(value),
      let strRawPayload = String(data: rawPayload, encoding: .utf8),
      let algorithm = JWTAlgorithm(rawValue: keyPair.algorithm.rawValue),
      let publicKey = keyPair.publicKey
    else {
      throw JWSEncoderError.invalidEncoding
    }

    let jwk: BITCrypto.JWK? = switch keyEncodingStrategy {
    case .jwk: try JWK(from: publicKey)
    case .none: nil
    }

    return JWS(
      payload: value,
      rawPayload: strRawPayload,
      rawJWS: rawJWS,
      header: JWSHeader(algorithm: algorithm, type: value.type, jwk: jwk))
  }

  // MARK: Private

  private func parseAlgorithm(_ algorithm: String) throws -> JSONWebSignatureAlgorithm {
    guard let jwtAlgorithm = JWTAlgorithm(rawValue: algorithm) else {
      throw JWSEncoderError.algorithmNotFound
    }
    return JSONWebSignatureAlgorithm(from: jwtAlgorithm)
  }

  private func header(using keyPair: VaultKeyPair, algorithm: JSONWebSignatureAlgorithm, type: String?, additionalParameters: [String: Any] = [:]) throws -> JOSEHeader {
    var header = JOSEHeader()
    header.algorithm = algorithm
    header.type = type.map { JSONWebContentType(rawValue: $0) }

    switch keyEncodingStrategy {
    case .jwk:
      header.key = keyPair.publicKey
    case .none:
      break
    }

    guard !additionalParameters.isEmpty else {
      return header
    }

    let data = try JSONSerialization.data(withJSONObject: additionalParameters)
    let additionalHeader = try JSONDecoder().decode(JOSEHeader.self, from: data)
    return header.merging(additionalHeader) { _, new in new }
  }

  private func createPayloadData(_ jwt: some Encodable) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = dateEncodingStrategy
    return try encoder.encode(jwt)
  }
}
