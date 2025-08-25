import BITAnyCredentialFormat
import BITEntities
import Foundation

// MARK: - CredentialClaim

public struct CredentialClaim: Codable, ClusterItem {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    key: String,
    value: String?,
    valueType: String = "string",
    valueDisplayInfo: String? = nil,
    order: Int = 0,
    displays: [CredentialClaimDisplay] = [])
  {
    self.id = id
    self.key = key
    self.value = value
    self.valueType = valueType
    self.valueDisplayInfo = valueDisplayInfo
    self.order = order
    self.displays = displays
    preferredDisplay = displays.findDisplayWithFallback() ?? CredentialClaimDisplay(name: key)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(UUID.self, forKey: .id)
    let key = try container.decode(String.self, forKey: .key)
    let value = try container.decodeIfPresent(String.self, forKey: .value)
    let valueType = try container.decode(String.self, forKey: .valueType)
    let valueDisplayInfo = try container.decodeIfPresent(String.self, forKey: .valueDisplayInfo)
    let order = try container.decode(Int.self, forKey: .order)
    let displays = try container.decode([CredentialClaimDisplay].self, forKey: .displays)

    self.init(
      id: id,
      key: key,
      value: value,
      valueType: valueType,
      valueDisplayInfo: valueDisplayInfo,
      order: order,
      displays: displays)
  }

  public init(_ entity: CredentialClaimEntity) {
    let displays = Array(entity.displays.map({ CredentialClaimDisplay($0) }))
    self.init(
      id: entity.id,
      key: entity.key,
      value: entity.value,
      valueType: entity.valueType,
      valueDisplayInfo: entity.valueDisplayInfo,
      order: Int(entity.order),
      displays: displays)
  }

  // MARK: Public

  public var id: UUID
  public var key: String
  public var value: String?
  public var valueType: String
  public var valueDisplayInfo: String?
  public var order: Int
  public var displays: [CredentialClaimDisplay]
  public var preferredDisplay: CredentialClaimDisplay?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case key
    case value
    case valueType = "value_type"
    case valueDisplayInfo = "value_display_info"
    case order
    case displays
  }
}

// MARK: Equatable

extension CredentialClaim: Equatable {

  public static func == (lhs: CredentialClaim, rhs: CredentialClaim) -> Bool {
    lhs.id == rhs.id &&
      lhs.key == rhs.key &&
      lhs.value == rhs.value &&
      lhs.valueType == rhs.valueType &&
      lhs.valueDisplayInfo == rhs.valueDisplayInfo &&
      lhs.order == rhs.order &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains)
  }

}
