import BITAnalytics
import BITCore
import CryptoKit
import Factory
import Foundation
import JWSETKit
import Security
import Spyable

// MARK: - JWEDecrypterError

public enum JWEDecrypterError: Error {
  case decrypterCreationFailed
  case maxCompressedCipherTextLengthExceeded
  case maxDecompressedSizeExceeded
  case invalidJWEFormat
  case unsupportedAlgorithm
  case keyAgreementFailed
}

// MARK: - JWEDecrypterProtocol

@Spyable
public protocol JWEDecrypterProtocol: Sendable {
  func decrypt(payload: Data, privateKey: SecKey, keyType: KeyType, limit: JWESizeLimit) throws -> Data
}

extension JWEDecrypterProtocol {
  public func decrypt(payload: Data, privateKey: SecKey, limit: JWESizeLimit) throws -> Data {
    try decrypt(payload: payload, privateKey: privateKey, keyType: .software, limit: limit)
  }
}

// MARK: - JWEDecrypter

struct JWEDecrypter: JWEDecrypterProtocol {

  // MARK: Internal

  func decrypt(payload: Data, privateKey: SecKey, keyType: KeyType, limit: JWESizeLimit) throws -> Data {
    guard String(decoding: payload, as: UTF8.self).count <= limit.maxCompressedCipherTextLength else {
      analytics.log(JWEDecrypterError.maxCompressedCipherTextLengthExceeded)
      throw JWEDecrypterError.maxCompressedCipherTextLengthExceeded
    }

    let jwe = try JSONWebEncryption(from: payload)

    let result = switch keyType {
    case .software: try softwareKeyDecryption(of: jwe, with: privateKey)
    case .hardware: try hardwareKeyDecryption(of: jwe, with: privateKey, limit: limit)
    }

    guard result.count <= limit.maxDecompressedSize else {
      analytics.log(JWEDecrypterError.maxDecompressedSizeExceeded)
      throw JWEDecrypterError.maxDecompressedSizeExceeded
    }
    return result
  }

  // MARK: Private

  @Injected(\.decrypter) private var decrypter: Decryptable
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.concatKeyDerivable) private var concatKeyDerivable: ConcatKeyDerivable

  private func softwareKeyDecryption(of jwe: JSONWebEncryption, with privateKey: SecKey) throws -> Data {
    var error: Unmanaged<CFError>?
    guard let keyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
      throw JWEDecrypterError.decrypterCreationFailed
    }
    let decryptionKey = try JSONWebECPrivateKey(importing: keyData, format: .raw)

    return try jwe.decrypt(using: decryptionKey)
  }

  private func hardwareKeyDecryption(of jwe: JSONWebEncryption, with privateKey: SecKey, limit: JWESizeLimit) throws -> Data {
    let header = jwe.header.protected.value

    guard
      header.algorithm == .ecdhEphemeralStatic,
      let contentAlgorithm = header.encryptionAlgorithm,
      let keyBitCount = contentAlgorithm.keyLength?.bitCount
    else {
      throw JWEDecrypterError.unsupportedAlgorithm
    }

    guard let ephemeralPublicKey = try header.ephemeralPublicKey?.toPublicSecKey() else {
      throw JWEDecrypterError.invalidJWEFormat
    }

    // Do the key agreement (ECDH) inside the Secure Enclave
    var error: Unmanaged<CFError>?
    guard let secret = SecKeyCopyKeyExchangeResult(privateKey, .ecdhKeyExchangeStandard, ephemeralPublicKey, [:] as CFDictionary, &error) as Data? else {
      analytics.log(JWEDecrypterError.keyAgreementFailed)
      throw JWEDecrypterError.keyAgreementFailed
    }

    // Turn the  secret into a AES key
    let encryptionKey = concatKeyDerivable.deriveKey(
      secret: secret,
      algorithm: contentAlgorithm,
      partyUInfo: header.agreementPartyUInfo ?? Data(),
      partyVInfo: header.agreementPartyVInfo ?? Data(),
      keyByteCount: keyBitCount / 8)

    var result = try decrypter.decrypt(
      jwe.sealed.combined,
      withSymmetricKey: SymmetricKey(data: encryptionKey),
      additionalAuthenticatedData: jwe.header.protected.encoded.urlBase64EncodedData())

    if header.compressionAlgorithm == .deflate {
      result = try result.decompressedWithLimit(limit.maxDecompressedSize, using: .zlib, ignoreHeaderBytes: false)
    }

    return result
  }
}
