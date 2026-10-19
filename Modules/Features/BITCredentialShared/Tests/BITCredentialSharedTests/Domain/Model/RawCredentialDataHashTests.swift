import BITCore
import BITEntities
import Foundation
import Testing
@testable import BITCredentialShared

// MARK: - RawCredentialDataHashTests

struct RawCredentialDataHashTests {

  // MARK: Internal

  enum Payload: CaseIterable {
    case plain
    /// A payload that is itself valid compressed bytes, so the stored form must not compress it twice.
    case alreadyCompressed
  }

  /// Re-hashing reads the persisted properties, so a hash taken from the incoming payload rather
  /// than from the form the row stores would not survive the second stamp.
  @Test(arguments: Payload.allCases)
  func contentHash_matchesTheStoredForm(payload: Payload) throws {
    let entity = try RawCredentialDataEntity(makeRawCredentialData(payload))
    let hashSetAtInit = entity.contentHash

    entity.updateContentHash()

    #expect(entity.contentHash == hashSetAtInit)
  }

  @Test(arguments: [true, false])
  func id_isDerivedFromTheContent(hasIdenticalContent: Bool) {
    let first = RawCredentialData(rawOIDMetadata: Self.metadata, rawOcaBundle: Self.bundle)
    let second = RawCredentialData(rawOIDMetadata: Self.metadata, rawOcaBundle: hasIdenticalContent ? Self.bundle : Data("other".utf8))

    #expect((first.id == second.id) == hasIdenticalContent)
  }

  @Test
  func storedForm_emptyPayload_isStoredAsAbsent() {
    let entity = RawCredentialDataEntity(rawOIDMetadata: Self.metadata, rawOcaBundle: Data())

    #expect(entity.rawOcaBundle == nil)
    #expect(entity.contentHash == RawCredentialDataEntity(rawOIDMetadata: Self.metadata, rawOcaBundle: nil).contentHash)
  }

  @Test
  func roundTrip_throughTheEntity_keepsTheHashAndTheContent() {
    let original = RawCredentialData(rawOIDMetadata: Self.metadata, rawOcaBundle: Self.bundle)

    let restored = RawCredentialData(RawCredentialDataEntity(original))

    #expect(restored.id == original.id)
    #expect(restored.rawOIDMetadata == original.rawOIDMetadata)
    #expect(restored.rawOcaBundle == original.rawOcaBundle)
  }

  @Test
  func decoding_derivesTheHashAndIgnoresAnEncodedOne() throws {
    let payload: [String: Any] = [
      "id": "36e626dd-0f32-4b0f-aee2-2b3115595cab",
      "rawOIDMetadata": Self.metadata.base64EncodedString(),
      "rawOcaBundle": Self.bundle.base64EncodedString(),
    ]
    let json = try JSONSerialization.data(withJSONObject: payload)

    let decoded = try JSONDecoder().decode(RawCredentialData.self, from: json)

    #expect(decoded.id == RawCredentialData(rawOIDMetadata: Self.metadata, rawOcaBundle: Self.bundle).id)
    #expect(decoded.rawOIDMetadata == Self.metadata)
    #expect(decoded.rawOcaBundle == Self.bundle)
  }

  // MARK: Private

  private static let metadata = Data(String(repeating: "{\"oid\":\"metadata\"}", count: 16).utf8)
  private static let bundle = Data(String(repeating: "{\"oca\":\"bundle\"}", count: 16).utf8)

  private func makeRawCredentialData(_ payload: Payload) throws -> RawCredentialData {
    switch payload {
    case .plain:
      return RawCredentialData(rawOIDMetadata: Self.metadata, rawOcaBundle: Self.bundle)
    case .alreadyCompressed:
      let compressed = try Self.metadata.compressed()
      return RawCredentialData(rawOIDMetadata: compressed, rawOcaBundle: nil)
    }
  }
}
