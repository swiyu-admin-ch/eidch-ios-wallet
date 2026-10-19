import BITCore
import BITEntities
import Foundation

// MARK: - RawCredentialData

public struct RawCredentialData: Identifiable, Codable, Equatable, Sendable {

  // MARK: Lifecycle

  public init(
    rawOIDMetadata: Data? = nil,
    rawOcaBundle: Data? = nil)
  {
    id = Self.contentHash(rawOIDMetadata: rawOIDMetadata, rawOcaBundle: rawOcaBundle)
    self.rawOIDMetadata = rawOIDMetadata
    self.rawOcaBundle = rawOcaBundle
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rawOIDMetadata = try container.decodeIfPresent(Data.self, forKey: .rawOIDMetadata)
    let rawOcaBundle = try container.decodeIfPresent(Data.self, forKey: .rawOcaBundle)
    self.init(rawOIDMetadata: rawOIDMetadata, rawOcaBundle: rawOcaBundle)
  }

  public init(_ entity: RawCredentialDataEntity) {
    id = entity.contentHash
    rawOIDMetadata = try? entity.rawOIDMetadata?.decompressed(ignoreHeaderBytes: false)
    rawOcaBundle = try? entity.rawOcaBundle?.decompressed(ignoreHeaderBytes: false)
  }

  // MARK: Public

  public let id: String
  public let rawOIDMetadata: Data?
  public let rawOcaBundle: Data?

  // MARK: Private

  private enum CodingKeys: CodingKey {
    case id
    case rawOIDMetadata
    case rawOcaBundle
  }

  private static func contentHash(rawOIDMetadata: Data?, rawOcaBundle: Data?) -> String {
    RawCredentialDataEntity(rawOIDMetadata: rawOIDMetadata, rawOcaBundle: rawOcaBundle).contentHash
  }
}
