import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITCore
import BITEntities
import BITOpenID
import Factory
import Foundation

// MARK: - CredentialClaim

public struct CredentialClaim: Codable, ClusterItem {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    path: ClaimsPathPointer,
    value: String?,
    valueType: String = "string",
    valueDisplayInfo: String? = nil,
    order: Int = 0,
    isSensitive: Bool = false,
    displays: [CredentialClaimDisplay] = [])
  {
    self.id = id
    self.path = path
    self.value = value
    self.valueType = valueType
    self.valueDisplayInfo = valueDisplayInfo
    self.order = order
    self.isSensitive = isSensitive
    self.displays = displays
    preferredDisplay = displays.findDisplayWithFallback() ?? CredentialClaimDisplay(name: path.stringValue)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(UUID.self, forKey: .id)
    let path = try container.decode(ClaimsPathPointer.self, forKey: .path)
    let value = try container.decodeIfPresent(String.self, forKey: .value)
    let valueType = try container.decode(String.self, forKey: .valueType)
    let valueDisplayInfo = try container.decodeIfPresent(String.self, forKey: .valueDisplayInfo)
    let order = try container.decode(Int.self, forKey: .order)
    let isSensitive = try container.decode(Bool.self, forKey: .isSensitive)
    let displays = try container.decode([CredentialClaimDisplay].self, forKey: .displays)

    self.init(
      id: id,
      path: path,
      value: value,
      valueType: valueType,
      valueDisplayInfo: valueDisplayInfo,
      order: order,
      isSensitive: isSensitive,
      displays: displays)
  }

  public init(_ entity: CredentialClaimEntity) {
    let displays = Array(entity.displays.map({ CredentialClaimDisplay($0) }))
    self.init(
      id: entity.id,
      path: ClaimsPathPointer(entity.path) ?? [],
      value: entity.value,
      valueType: entity.valueType,
      valueDisplayInfo: entity.valueDisplayInfo,
      order: Int(entity.order),
      isSensitive: entity.isSensitive,
      displays: displays)
  }

  // MARK: Public

  public var id: UUID
  public var path: ClaimsPathPointer
  public var value: String?
  public var valueType: String
  public var valueDisplayInfo: String?
  public var order: Int
  public var isSensitive: Bool
  public var displays: [CredentialClaimDisplay]
  public var preferredDisplay: CredentialClaimDisplay

  public var localizedValue: String {
    let label: String
    if let localizedValue = preferredDisplay.value {
      label = localizedValue
    } else {
      let claimValue = switch ValueType(rawValue: valueType) {
      case .dateTime: dateTimeFormatted()
      case .numeric: numericFormatted()
      default: value
      }
      label = claimValue ?? "–"
    }
    // truncating after reasonable length, size of A4 document
    return label.count > 1800 ? String(label.prefix(1800) + "…") : label
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case path
    case value
    case valueType = "value_type"
    case valueDisplayInfo = "value_display_info"
    case order
    case isSensitive = "is_sensitive"
    case displays
  }

  // MARK: Private

  private var currentLocale: Locale {
    Locale(identifier: Container.shared.preferredUserLocales().first ?? UserLocale.defaultLocaleIdentifier)
  }

  private func dateTimeFormatted() -> String? {
    guard
      let rawFormat = valueDisplayInfo,
      let format = DateFormat(rawValue: rawFormat),
      let value,
      let date = ISO8601DateFormatter().date(from: value) else
    {
      return value
    }

    let formatter = DateFormatter()
    formatter.locale = currentLocale
    formatter.timeZone = format.hasTimeZone ? Container.shared.userTimeZone() : .gmt
    formatter.dateStyle = format.hasDate ? .short : .none

    if format.hasSeconds {
      formatter.timeStyle = .medium
    } else if format.hasTime {
      formatter.timeStyle = .short
    } else {
      formatter.timeStyle = .none
    }

    if format == .yearMonth {
      formatter.dateFormat = "MMMM yyyy"
    } else if format == .year {
      formatter.dateFormat = "yyyy"
    }

    return formatter.string(from: date)
  }

  private func numericFormatted() -> String? {
    guard let value else { return nil }
    let inputFormatter = NumberFormatter()
    let outputFormatter = NumberFormatter()
    outputFormatter.locale = currentLocale
    outputFormatter.maximumFractionDigits = 14 // maximum Double precision

    if value.range(of: "e", options: [.regularExpression, .caseInsensitive]) != nil {
      outputFormatter.numberStyle = .scientific
      outputFormatter.minimumIntegerDigits = getIntegerDigitsFromScientificNotation(value)
      outputFormatter.exponentSymbol = value.contains("E") ? "E" : "e"
    } else {
      outputFormatter.numberStyle = .decimal
    }

    if
      let number = inputFormatter.number(from: value),
      let output = outputFormatter.string(from: number)
    {
      return output
    }
    return value
  }

  private func getIntegerDigitsFromScientificNotation(_ value: String) -> Int {
    let regex = #/^[+-]?([0-9]+)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?$/#
    guard let match = value.wholeMatch(of: regex) else {
      return 0
    }
    return match.1.count
  }

}

// MARK: Equatable

extension CredentialClaim: Equatable {

  public static func == (lhs: CredentialClaim, rhs: CredentialClaim) -> Bool {
    lhs.id == rhs.id &&
      lhs.path == rhs.path &&
      lhs.value == rhs.value &&
      lhs.valueType == rhs.valueType &&
      lhs.valueDisplayInfo == rhs.valueDisplayInfo &&
      lhs.order == rhs.order &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains)
  }
}
