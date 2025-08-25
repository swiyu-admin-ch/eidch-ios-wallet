import BITCore
import BITCredentialShared
import BITEntities
import Factory
import Foundation

struct CredentialClaimViewModel {

  // MARK: Lifecycle

  init(_ claim: CredentialClaim) {
    self.claim = claim
  }

  // MARK: Internal

  var imageData: Data? {
    guard let type = valueType, type.isImage else { return nil }
    return claim.value.flatMap { Data(base64Encoded: $0) }
  }

  var nameLabel: String {
    claim.preferredDisplay?.name ?? claim.key
  }

  var valueLabel: String {
    var label: String
    if let localizedValue = claim.preferredDisplay?.value {
      label = localizedValue
    } else {
      let claimValue = switch valueType {
      case .dateTime: dateTimeFormatted()
      case .numeric: numericFormatted()
      default: claim.value
      }
      label = claimValue ?? "-"
    }
    // truncating after reasonable length, size of A4 document
    return label.count > 1800 ? String(label.prefix(1800) + "…") : label
  }

  // MARK: Private

  private let claim: CredentialClaim

  private var valueType: ValueType? {
    ValueType(rawValue: claim.valueType)
  }

  private var currentLocale: Locale {
    Locale(identifier: Container.shared.preferredUserLocales().first ?? UserLocale.defaultLocaleIdentifier)
  }

  private func dateTimeFormatted() -> String? {
    guard
      let rawFormat = claim.valueDisplayInfo,
      let format = DateParserResult.Format(rawValue: rawFormat),
      let value = claim.value,
      let date = ISO8601DateFormatter().date(from: value) else
    {
      return claim.value
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
    guard let value = claim.value else { return nil }
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
