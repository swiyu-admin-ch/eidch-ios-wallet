import BITCrypto
import BITVault
import Foundation
import JOSESwift

// MARK: - JWSEncoderProtocol

public protocol JWSEncoderProtocol {
  func encode(_ value: some JWTPayload & Encodable, using keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> Data
  func encode<T>(_ value: T, keyPair: VaultKeyPair) throws -> JWS<T> where T: JWTPayload & Encodable
}

extension JWSEncoderProtocol {
  public func encode(_ value: some JWTPayload & Encodable, using keyPair: VaultKeyPair) throws -> Data {
    try encode(value, using: keyPair, additionalHeaderParameters: [:])
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

  public func encode(_ jwtPayload: some JWTPayload & Encodable, using keyPair: VaultKeyPair, additionalHeaderParameters: [String: Any]) throws -> Data {
    let algorithm = try parseAlgorithm(keyPair.algorithm.rawValue)
    let header = try header(using: keyPair, algorithm: algorithm, type: jwtPayload.type, additionalParameters: additionalHeaderParameters)
    let payload = try createPayload(jwtPayload)
    guard let signer = Signer(signingAlgorithm: algorithm, key: keyPair.privateKey) else {
      throw JWSEncoderError.wrongKeyType
    }
    let jws = try JOSESwift.JWS(header: header, payload: payload, signer: signer)
    return jws.compactSerializedData
  }

  public func encode<T>(_ value: T, keyPair: VaultKeyPair) throws -> JWS<T> where T: JWTPayload & Encodable {
    let data = try encode(value, using: keyPair)

    guard
      let rawJWS = String(data: data, encoding: .utf8),
      let rawPayload = try? JSONEncoder().encode(value),
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
      rawJWS: rawJWS,
      rawPayload: strRawPayload,
      header: JWSHeader(algorithm: algorithm, type: value.type, jwk: jwk))
  }

  // MARK: Private

  private func parseAlgorithm(_ algorithm: String) throws -> SignatureAlgorithm {
    guard let jwtAlgorithm = JWTAlgorithm(rawValue: algorithm) else {
      throw JWSEncoderError.algorithmNotFound
    }
    return try SignatureAlgorithm(from: jwtAlgorithm)
  }

  private func header(using keyPair: VaultKeyPair, algorithm: SignatureAlgorithm, type: String?, additionalParameters: [String: Any]) throws -> JOSESwift.JWSHeader {
    var parameters: [String: Any] = if let typ = type { ["typ": typ] } else { [:] }
    switch keyEncodingStrategy {
    case .jwk:
      parameters["jwk"] = try createJwk(keyPair: keyPair).parameters
    case .none:
      break
    }
    parameters[JWKParameter.algorithm.rawValue] = algorithm.rawValue
    parameters.merge(additionalParameters) { _, new in new }
    return try JOSESwift.JWSHeader(parameters: parameters)
  }

  private func createJwk(keyPair: VaultKeyPair) throws -> JOSESwift.JWK {
    guard let publicKey = keyPair.publicKey, let jwk = try? ECPublicKey(publicKey: publicKey) else {
      throw JWSEncoderError.cannotCreateJwk
    }
    return jwk
  }

  private func createPayload(_ jwtPayload: some Encodable) throws -> Payload {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = dateEncodingStrategy
    let payloadData = try encoder.encode(jwtPayload)
    return Payload(payloadData)
  }
}
