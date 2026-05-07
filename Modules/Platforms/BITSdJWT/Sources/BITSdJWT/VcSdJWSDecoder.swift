import BITCore
import BITJWT
import Foundation

// MARK: - VcSdJWSDecoderError

enum VcSdJWSDecoderError: Error, Equatable {
  case unregisteredNonSelectivelyDisclosableClaimFound
}

// MARK: - VcSdJWSDecoderProtocol

public protocol VcSdJWSDecoderProtocol {
  func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> SdJWS<T>
}

// MARK: - VcSdJWSDecoder

public struct VcSdJWSDecoder: VcSdJWSDecoderProtocol {

  // MARK: Lifecycle

  public init(sdJwsDecoder: SdJWSDecoderProtocol = SdJWSDecoder(nonSelectivelyDisclosableClaims: nonSelectivelyDisclosableClaims)) {
    self.sdJwsDecoder = sdJwsDecoder
  }

  // MARK: Public

  public static let nonSelectivelyDisclosableClaims = [
    "iss", "nbf", "exp", "iat", "cnf", "status",
    "_sd", "_sd_alg",
    "vct", "vct#integrity", "vct_metadata_uri", "vct_metadata_uri#integrity",
  ]

  public func decode<T: JWT>(_ type: T.Type, from data: Data) throws -> SdJWS<T> {
    let vcSdJws = try sdJwsDecoder.decode(type, from: data)
    let payloadData = Data(vcSdJws.rawPayload.utf8)
    guard
      let payload = try JSONSerialization.jsonObject(with: payloadData) as? JSON,
      payload.keys.allSatisfy({ Self.nonSelectivelyDisclosableClaims.contains($0) })
    else {
      throw VcSdJWSDecoderError.unregisteredNonSelectivelyDisclosableClaimFound
    }
    return vcSdJws
  }

  // MARK: Private

  private let sdJwsDecoder: SdJWSDecoderProtocol
}
