import BITEntities
import Foundation

// MARK: - RawCredentialData

public struct RawCredentialData: Identifiable, Codable {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    rawOIDMetadata: Data? = nil,
    rawOcaBundle: Data? = nil)
  {
    self.id = id
    self.rawOIDMetadata = rawOIDMetadata
    self.rawOcaBundle = rawOcaBundle
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    rawOIDMetadata = try container.decodeIfPresent(Data.self, forKey: .rawOIDMetadata)
    rawOcaBundle = try container.decodeIfPresent(Data.self, forKey: .rawOcaBundle)
  }

  public init(_ entity: RawCredentialDataEntity) {
    self.init(
      id: entity.id,
      rawOIDMetadata: try? entity.rawOIDMetadata?.decompressed(ignoreHeaderBytes: false),
      rawOcaBundle: try? entity.rawOcaBundle?.decompressed(ignoreHeaderBytes: false))
  }

  // MARK: Public

  public let id: UUID
  public let rawOIDMetadata: Data?
  public let rawOcaBundle: Data?

  // MARK: Private

  private enum CodingKeys: CodingKey {
    case id
    case rawOIDMetadata
    case rawOcaBundle
  }
}

// MARK: Equatable

extension RawCredentialData: Equatable {

  public static func == (lhs: RawCredentialData, rhs: RawCredentialData) -> Bool {
    lhs.id == rhs.id &&
      lhs.rawOIDMetadata == rhs.rawOIDMetadata &&
      lhs.rawOcaBundle == rhs.rawOcaBundle
  }
}
