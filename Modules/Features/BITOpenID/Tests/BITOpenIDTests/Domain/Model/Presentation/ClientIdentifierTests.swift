import Foundation
import Testing
@testable import BITOpenID

@Suite
struct ClientIdentifierTests {

  // MARK: Internal

  // MARK: Parsing

  @Test
  func init_noPrefix_returnsClientIdentifier() throws {
    let identifier = try ClientIdentifier(rawClientId: didMock)

    #expect(identifier.raw == didMock)
    #expect(identifier.clientId == didMock)
    #expect(identifier.prefix == .decentralizedIdentifier)
  }

  @Test
  func init_decentralizedIdentifierPrefix_returnsClientIdentifier() throws {
    let clientId = didPrefix + didMock

    let identifier = try ClientIdentifier(rawClientId: clientId)

    #expect(identifier.raw == clientId)
    #expect(identifier.clientId == didMock)
    #expect(identifier.prefix == .decentralizedIdentifier)
  }

  @Test
  func init_verifierAttestationPrefix_returnsClientIdentifier() throws {
    let clientId = attestationPrefix + "test app"

    let identifier = try ClientIdentifier(rawClientId: clientId)

    #expect(identifier.raw == clientId)
    #expect(identifier.clientId == "test app")
    #expect(identifier.prefix == .verifierAttestation)
  }

  @Test(arguments: [
    "",
    "invalid",
    "foo:bar",
    "https://example.com",
    "decentralized_identifier:",
    "verifier_attestation:",
  ])
  func init_invalidClientId_throwsError(raw: String) {
    #expect(throws: ClientIdentifierError.invalidClientId) {
      try ClientIdentifier(rawClientId: raw)
    }
  }

  // MARK: Codable

  @Test
  func decode_noPrefix_returnsClientIdentifier() throws {
    let data = try JSONEncoder().encode(didMock)

    let identifier = try JSONDecoder().decode(ClientIdentifier.self, from: data)

    #expect(identifier.raw == didMock)
    #expect(identifier.clientId == didMock)
    #expect(identifier.prefix == .decentralizedIdentifier)
  }

  @Test
  func decode_decentralizedIdentifierPrefix_returnsClientIdentifier() throws {
    let clientId = didPrefix + didMock

    let data = try JSONEncoder().encode(clientId)

    let identifier = try JSONDecoder().decode(ClientIdentifier.self, from: data)

    #expect(identifier.raw == clientId)
    #expect(identifier.clientId == didMock)
    #expect(identifier.prefix == .decentralizedIdentifier)
  }

  @Test
  func decode_verifierAttestationPrefix_returnsClientIdentifier() throws {
    let clientId = attestationPrefix + didMock
    let data = try JSONEncoder().encode(clientId)

    let identifier = try JSONDecoder().decode(ClientIdentifier.self, from: data)

    #expect(identifier.raw == clientId)
    #expect(identifier.clientId == didMock)
    #expect(identifier.prefix == .verifierAttestation)
  }

  @Test
  func decode_invalidClientId_throwsError() throws {
    let data = try JSONEncoder().encode("invalid")

    #expect(throws: ClientIdentifierError.invalidClientId) {
      _ = try JSONDecoder().decode(ClientIdentifier.self, from: data)
    }
  }

  @Test
  func encode_returnsRawValue() throws {
    let clientId = attestationPrefix + didMock

    let identifier = try ClientIdentifier(rawClientId: clientId)

    let data = try JSONEncoder().encode(identifier)
    let decoded = try JSONDecoder().decode(String.self, from: data)

    #expect(decoded == clientId)
  }

  @Test
  func codable_roundTrip_preservesValues() throws {
    let original = try ClientIdentifier(rawClientId: attestationPrefix + didMock)

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(ClientIdentifier.self, from: data)

    #expect(decoded == original)
  }

  // MARK: Private

  private let didPrefix = ClientIdentifier.Prefix.decentralizedIdentifier.rawValue + ":"
  private let attestationPrefix = ClientIdentifier.Prefix.verifierAttestation.rawValue + ":"
  private let didMock = "did:example:123"
}
