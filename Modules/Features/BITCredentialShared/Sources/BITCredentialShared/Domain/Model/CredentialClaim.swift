import BITAnyCredentialFormat
import BITCore
import BITEntities
import Foundation

// MARK: - CredentialClaim

public struct CredentialClaim: Codable {

  // MARK: Lifecycle

  public init(id: UUID = UUID(), key: String, valueType: String = "string", value: String, order: Int16 = 0, credentialId: UUID? = nil, displays: [CredentialClaimDisplay] = []) {
    self.id = id
    self.key = key
    self.valueType = valueType
    self.value = value
    self.order = order
    self.credentialId = credentialId
    self.displays = displays
    preferredDisplay = displays.findDisplayWithFallback() as? CredentialClaimDisplay ?? CredentialClaimDisplay(name: key)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(UUID.self, forKey: .id)
    let key = try container.decode(String.self, forKey: .key)
    let valueType = try container.decode(String.self, forKey: .valueType)
    let value = try container.decode(String.self, forKey: .value)
    let order = try container.decode(Int16.self, forKey: .order)
    let credentialId = try container.decodeIfPresent(UUID.self, forKey: .credentialId)
    let displays = try container.decode([CredentialClaimDisplay].self, forKey: .displays)

    self.init(
      id: id,
      key: key,
      valueType: valueType,
      value: value,
      order: order,
      credentialId: credentialId,
      displays: displays)
  }

  public init(_ entity: CredentialClaimEntity) {
    let displays = Array(entity.displays.map({ CredentialClaimDisplay($0) }))
    self.init(
      id: entity.id,
      key: entity.key,
      valueType: entity.valueType,
      value: entity.value,
      order: entity.order,
      credentialId: entity.credential.first?.id,
      displays: displays)
  }

  // MARK: Public

  public var id: UUID
  public var key: String
  public var valueType: String
  public var value: String
  public var order: Int16
  public var credentialId: UUID?
  public var displays: [CredentialClaimDisplay]
  public var preferredDisplay: CredentialClaimDisplay?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case key
    case valueType = "value_type"
    case value
    case order
    case credentialId = "credential_id"
    case displays
  }

}

extension CredentialClaim {

  public var type: ValueType? {
    ValueType(rawValue: valueType)
  }

  public var imageData: Data? {
    (type?.isImage ?? false) ? Data(base64Encoded: value) : nil
  }

}

// MARK: Equatable

extension CredentialClaim: Equatable {

  public static func == (lhs: CredentialClaim, rhs: CredentialClaim) -> Bool {
    lhs.id == rhs.id &&
      lhs.key == rhs.key &&
      lhs.valueType == rhs.valueType &&
      lhs.value == rhs.value &&
      lhs.order == rhs.order &&
      lhs.credentialId == rhs.credentialId
  }

}
