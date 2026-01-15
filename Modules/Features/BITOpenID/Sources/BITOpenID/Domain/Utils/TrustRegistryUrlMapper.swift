import Factory
import Foundation
import RegexBuilder
import Spyable

// MARK: - TrustRegistryUrlMapperProtocol

@Spyable
public protocol TrustRegistryUrlMapperProtocol {
  func map(did: String) throws -> URL
}

// MARK: - TrustRegistryUrlMapperError

public enum TrustRegistryUrlMapperError: Error {
  case cannotParseTrustRegistryDomain
}

// MARK: - TrustRegistryUrlMapper

struct TrustRegistryUrlMapper: TrustRegistryUrlMapperProtocol {

  // MARK: Internal

  func map(did: String) throws -> URL {
    guard
      let baseRegistryDomain = try getBaseRegistryDomain(from: did),
      let trustRegistryDomain = trustRegistryMapping[baseRegistryDomain],
      let trustRegistryURL = URL(string: "https://\(trustRegistryDomain)")
    else {
      throw TrustRegistryUrlMapperError.cannotParseTrustRegistryDomain
    }
    return trustRegistryURL
  }

  // MARK: Private

  private static var didPartCharacters = OneOrMore(CharacterClass.anyOf(":").inverted)
  private static let baseRegistryDomainReference = Reference(String.self)
  private static var baseRegistryDomain = Capture(as: baseRegistryDomainReference) {
    didPartCharacters
    ".swiyu"
    Optionally("-int")
    ".admin.ch"
  } transform: {
    String($0)
  }

  private static var baseRegistryDidPattern = Regex {
    Anchor.startOfLine
    "did:tdw:"
    didPartCharacters
    ":"
    baseRegistryDomain
    OneOrMore {
      ":"
      didPartCharacters
    }
    Anchor.endOfLine
  }

  @Injected(\.trustRegistryMapping) private var trustRegistryMapping: [String: String]

  private func getBaseRegistryDomain(from did: String) throws -> String? {
    guard let match = try Self.baseRegistryDidPattern.wholeMatch(in: did) else { return nil }
    return match[Self.baseRegistryDomainReference]
  }
}
