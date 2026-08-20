import BITAnalytics
import BITCore
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
}

// MARK: - JWEDecrypterProtocol

@Spyable
public protocol JWEDecrypterProtocol {
  func decrypt(payload: Data, privateKey: SecKey) throws -> Data
}

// MARK: - JWEDecrypter

public struct JWEDecrypter: JWEDecrypterProtocol {

  // MARK: Public

  public func decrypt(payload: Data, privateKey: SecKey) throws -> Data {
    guard String(decoding: payload, as: UTF8.self).count <= Self.maxCompressedCipherTextLength else {
      analytics.log(JWEDecrypterError.maxCompressedCipherTextLengthExceeded)
      throw JWEDecrypterError.maxCompressedCipherTextLengthExceeded
    }
    let jwe = try JSONWebEncryption(from: payload)
    var error: Unmanaged<CFError>?
    guard let keyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
      throw JWEDecrypterError.decrypterCreationFailed
    }
    let decryptionKey = try JSONWebECPrivateKey(importing: keyData, format: .raw)

    let result = try jwe.decrypt(using: decryptionKey)
    guard result.count <= Self.maxDecompressedSize else {
      analytics.log(JWEDecrypterError.maxDecompressedSizeExceeded)
      throw JWEDecrypterError.maxDecompressedSizeExceeded
    }
    return result
  }

  // MARK: Private

  private static let maxDecompressedSize = 20 * 1024 * 1024 // 20MB
  private static let maxCompressedCipherTextLength = 6_000_000 // credentials containing large images etc. have max 5.5mio for now so use 6mio

  @Injected(\.analytics) private var analytics
}
