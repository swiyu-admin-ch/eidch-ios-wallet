import BITCore
import BITEntities
import Foundation

extension RawCredentialDataEntity {

  // MARK: Lifecycle

  convenience init(rawOIDMetadata: Data?, rawOcaBundle: Data?) {
    self.init()
    self.rawOIDMetadata = Self.stored(rawOIDMetadata)
    self.rawOcaBundle = Self.stored(rawOcaBundle)
    updateContentHash()
  }

  convenience init(_ rawCredentialData: RawCredentialData) {
    self.init(rawOIDMetadata: rawCredentialData.rawOIDMetadata, rawOcaBundle: rawCredentialData.rawOcaBundle)
  }

  // MARK: Private

  /// A payload that failed to compress is stored as it came in rather than dropped: the row is
  /// keyed by what it stores, so dropping it would key this row as one that never held that
  /// payload, and every row that lost its payload would collapse onto that same one. Storing the
  /// bytes keeps the row distinct, and the loss stays with the credential it happened to.
  ///
  /// Empty data has no compressed form and is the failure the compressor actually reports, so it
  /// is answered with the absence it already means.
  private static func stored(_ payload: Data?) -> Data? {
    guard let payload, !payload.isEmpty else { return nil }

    do {
      return try payload.compressed()
    } catch {
      assertionFailure("Failed to compress \(payload.count) bytes of raw credential data: \(error)")
      return payload
    }
  }

}
