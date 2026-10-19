import CryptoKit
import Foundation
import JWSETKit
import Spyable

// MARK: - ConcatKeyDerivable

@Spyable
protocol ConcatKeyDerivable: Sendable {

  /// Derives a symmetric key from an ECDH shared secret.
  ///
  /// - Parameters:
  ///   - secret: Secret created by the key agreement
  ///   - algorithm: Algorithm used for the derivation
  ///   - partyUInfo: The `apu` agreement context, or empty when absent.
  ///   - partyVInfo: The `apv` agreement context, or empty when absent.
  ///   - keyByteCount: The desired key length in bytes.
  /// - Returns: The derived key
  func deriveKey(secret: Data, algorithm: any JSONWebAlgorithm, partyUInfo: Data, partyVInfo: Data, keyByteCount: Int) -> Data

}

// MARK: - ConcatKDF

struct ConcatKDF: ConcatKeyDerivable {

  // MARK: Internal

  func deriveKey(secret: Data, algorithm: any JSONWebAlgorithm, partyUInfo: Data, partyVInfo: Data, keyByteCount: Int) -> Data {
    let otherInfo = lengthPrefixed(Data(algorithm.rawValue.utf8))
      + lengthPrefixed(partyUInfo)
      + lengthPrefixed(partyVInfo)
      + uInt32BE(UInt32(keyByteCount * 8))

    let block = uInt32BE(1) + secret + otherInfo
    return Data(SHA256.hash(data: block)).prefix(keyByteCount)
  }

  // MARK: Private

  private func lengthPrefixed(_ data: Data) -> Data {
    uInt32BE(UInt32(data.count)) + data
  }

  private func uInt32BE(_ value: UInt32) -> Data {
    withUnsafeBytes(of: value.bigEndian) { Data($0) }
  }
}
