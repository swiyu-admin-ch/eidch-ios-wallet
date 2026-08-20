import Foundation

// MARK: - ClientIdentifier

/// Parsed `client_id` of an OpenID4VP request, split into its Client Identifier Prefix and original Client Identifer.
/// https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-defined-client-identifier-p
public struct ClientIdentifier: Equatable, Codable {

  // MARK: Lifecycle

  init(rawClientId: String) throws {
    raw = rawClientId
    let split = raw.split(separator: ":", maxSplits: 1).map(String.init)
    if split.count == 2, let prefix = Prefix(rawValue: split[0]) {
      let identifier = split[1]
      switch prefix {
      case .decentralizedIdentifier:
        guard identifier.matchesDid else { throw ClientIdentifierError.invalidClientId }
      case .verifierAttestation:
        guard !identifier.isEmpty else { throw ClientIdentifierError.invalidClientId }
      }

      self.prefix = prefix
      clientId = identifier
      return
    }

    guard raw.matchesDid else { throw ClientIdentifierError.invalidClientId }
    prefix = .decentralizedIdentifier
    clientId = raw
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawString = try container.decode(String.self)
    try self.init(rawClientId: rawString)
  }

  // MARK: Public

  public let clientId: String
  public let raw: String

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(raw)
  }

  // MARK: Internal

  enum Prefix: String, CaseIterable {
    case decentralizedIdentifier = "decentralized_identifier"
    case verifierAttestation = "verifier_attestation"
  }

  let prefix: Prefix
}

extension ClientIdentifier {
  public static func == (lhs: ClientIdentifier, rhs: ClientIdentifier) -> Bool {
    lhs.raw.normalizedDid() == rhs.raw.normalizedDid()
  }
}

// MARK: - ClientIdentifierError

enum ClientIdentifierError: Error, Equatable {
  case invalidClientId
}
