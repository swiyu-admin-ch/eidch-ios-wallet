import Foundation
import Spyable

@Spyable
public protocol SdJWTDecoderProtocol {
  func decodeDigests(from rawCredential: String) throws -> [SdJwtDigest]
  func decodeClaims(from rawCredential: String, digests: [SdJwtDigest]) throws -> [SdJWTClaim]
}
