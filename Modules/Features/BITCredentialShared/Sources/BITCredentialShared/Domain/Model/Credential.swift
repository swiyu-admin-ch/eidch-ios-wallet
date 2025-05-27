import BITAnyCredentialFormat
import BITCore
import BITCrypto
import BITEntities
import BITVault
import Factory
import Foundation

// MARK: - CredentialError

public enum CredentialError: Error {
  case selectedCredentialNotFound
  case invalidDisplay
  case invalidPayload
}

// MARK: - Credential

public struct Credential: Identifiable, Codable {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    status: CredentialStatus = .unknown,
    keyBindingIdentifier: UUID? = nil,
    keyBindingAlgorithm: String? = nil,
    payload: CredentialPayload,
    format: String,
    issuer: String,
    validFrom: Date? = nil,
    validUntil: Date? = nil,
    createdAt: Date = Date(),
    updatedAt: Date? = nil,
    claims: [CredentialClaim] = [],
    issuerDisplays: [CredentialIssuerDisplay] = [],
    displays: [CredentialDisplay] = [])
  {
    self.id = id
    self.status = status
    self.keyBindingIdentifier = keyBindingIdentifier
    self.keyBindingAlgorithm = keyBindingAlgorithm
    self.payload = payload
    self.format = format
    self.issuer = issuer
    self.validFrom = validFrom
    self.validUntil = validUntil
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.claims = claims
    self.issuerDisplays = issuerDisplays
    self.displays = displays

    environment = .none
    if let regex = try? Regex(demoCredentialPattern), !issuer.matches(of: regex).isEmpty {
      environment = .demo
    }

    preferredDisplay = displays.findDisplayWithFallback() as? CredentialDisplay
    preferredIssuerDisplay = issuerDisplays.findDisplayWithFallback() as? CredentialIssuerDisplay
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    try self.init(
      id: container.decode(UUID.self, forKey: .id),
      status: container.decode(CredentialStatus.self, forKey: .status),
      keyBindingIdentifier: container.decodeIfPresent(UUID.self, forKey: .keyBindingIdentifier),
      keyBindingAlgorithm: container.decodeIfPresent(String.self, forKey: .keyBindingAlgorithm),
      payload: container.decode(Data.self, forKey: .payload),
      format: container.decode(String.self, forKey: .format),
      issuer: container.decode(String.self, forKey: .issuer),
      validFrom: container.decodeIfPresent(Date.self, forKey: .validFrom),
      validUntil: container.decodeIfPresent(Date.self, forKey: .validUntil),
      createdAt: container.decode(Date.self, forKey: .createdAt),
      updatedAt: container.decodeIfPresent(Date.self, forKey: .updatedAt),
      claims: container.decode([CredentialClaim].self, forKey: .claims),
      issuerDisplays: container.decode([CredentialIssuerDisplay].self, forKey: .issuerDisplays),
      displays: container.decode([CredentialDisplay].self, forKey: .displays))
  }

  public init(_ entity: CredentialEntity) {
    let claims = Array(entity.claims.map({ CredentialClaim($0) }))
    let issuerDisplays = Array(entity.issuerDisplays.map({ CredentialIssuerDisplay($0) }))
    let displays = Array(entity.displays.map({ CredentialDisplay($0) }))

    self.init(
      id: entity.id,
      status: CredentialStatus(rawValue: entity.status) ?? .unknown,
      keyBindingIdentifier: entity.keyBindingIdentifier,
      keyBindingAlgorithm: entity.keyBindingAlgorithm,
      payload: entity.payload,
      format: entity.format,
      issuer: entity.issuer,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      claims: claims,
      issuerDisplays: issuerDisplays,
      displays: displays)
  }

  // MARK: Public

  public var id = UUID()
  public var status = CredentialStatus.unknown
  public var keyBindingIdentifier: UUID? = nil
  public var keyBindingAlgorithm: String? = nil
  public var payload: CredentialPayload
  public var format: String
  public var issuer: String

  public var validFrom: Date? = nil
  public var validUntil: Date? = nil
  public var createdAt = Date()
  public var updatedAt: Date? = nil

  public var claims: [CredentialClaim] = []
  public var issuerDisplays: [CredentialIssuerDisplay] = []
  public var displays: [CredentialDisplay] = []

  public var preferredDisplay: CredentialDisplay?
  public var preferredIssuerDisplay: CredentialIssuerDisplay?
  public var environment: CredentialEnvironment? = .none

  // MARK: Private

  private enum CodingKeys: CodingKey {
    case id
    case status
    case keyBindingIdentifier
    case keyBindingAlgorithm
    case payload
    case format
    case issuer
    case validFrom
    case validUntil
    case createdAt
    case updatedAt
    case claims
    case issuerDisplays
    case displays
    case preferredDisplay
    case preferredIssuerDisplay
  }

  @Injected(\.demoCredentialPattern) private var demoCredentialPattern: String
}

// MARK: Equatable

extension Credential: Equatable {

  public static func == (lhs: Credential, rhs: Credential) -> Bool {
    lhs.id == rhs.id &&
      lhs.status == rhs.status &&
      lhs.keyBindingIdentifier == rhs.keyBindingIdentifier &&
      lhs.keyBindingAlgorithm == rhs.keyBindingAlgorithm &&
      lhs.payload == rhs.payload &&
      lhs.format == rhs.format &&
      lhs.issuer == rhs.issuer &&
      lhs.validFrom == rhs.validFrom &&
      lhs.validUntil == rhs.validUntil &&
      lhs.createdAt == rhs.createdAt &&
      lhs.updatedAt == rhs.updatedAt &&
      lhs.claims.map({ claimLhs in rhs.claims.contains(where: { $0 == claimLhs }) }).allSatisfy({ $0 }) &&
      lhs.issuerDisplays.map({ issuerLhs in rhs.issuerDisplays.contains(where: { $0 == issuerLhs }) }).allSatisfy({ $0 }) &&
      lhs.displays.map({ displayLhs in rhs.displays.contains(where: { $0 == displayLhs }) }).allSatisfy({ $0 })
  }
}
