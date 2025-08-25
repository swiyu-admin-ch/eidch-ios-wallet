import BITOca
import Foundation
import Spyable

// MARK: - OverlayAttributeDateParserProtocol

@Spyable
protocol OverlayAttributeDateParserProtocol {
  func parse(_ dateString: String, with ocaAttribute: OverlayBundleAttribute) -> DateParserResult?
}

// MARK: - OverlayAttributeDateParser

struct OverlayAttributeDateParser: OverlayAttributeDateParserProtocol {

  // MARK: Internal

  func parse(_ dateString: String, with ocaAttribute: OverlayBundleAttribute) -> DateParserResult? {
    if ocaAttribute.standard == .dateTimeUnixEpoch {
      return parseUnixEpoch(dateString)
    }

    return parseISO8601(dateString)
  }

  // MARK: Private

  private func parseISO8601(_ dateString: String) -> DateParserResult? {
    let formatter = DateFormatter()
    formatter.timeZone = .gmt

    for format in DateParserResult.Format.allCases {
      formatter.dateFormat = format.rawValue
      if let date = formatter.date(from: dateString) {
        let output = ISO8601DateFormatter().string(from: date)
        return DateParserResult(normalizedDate: output, format: format)
      }
    }

    return nil
  }

  private func parseUnixEpoch(_ dateString: String) -> DateParserResult? {
    guard let seconds = TimeInterval(dateString) else { return nil }
    let date = Date(timeIntervalSince1970: seconds)
    let iso8601Date = ISO8601DateFormatter().string(from: date)
    return DateParserResult(normalizedDate: iso8601Date, format: .dateTimeTimeZoneSeconds)
  }
}

// MARK: - DateParserResult

struct DateParserResult {

  enum Format: String, CaseIterable {
    case dateTimeTimeZoneSecondsFractional = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case dateTimeTimeZoneSeconds = "yyyy-MM-dd'T'HH:mm:ssZ"
    case dateTimeTimeZone = "yyyy-MM-dd'T'HH:mmZ"
    case dateTimeSecondsFractional = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    case dateTimeSeconds = "yyyy-MM-dd'T'HH:mm:ss"
    case dateTime = "yyyy-MM-dd'T'HH:mm"
    case dateTimeZone = "yyyy-MM-ddZ"
    case date = "yyyy-MM-dd"
    case timeTimeZoneSecondsFractional = "HH:mm:ss.SSSZ"
    case timeTimeZoneSeconds = "HH:mm:ssZ"
    case timeTimeZone = "HH:mmZ"
    case timeSecondsFractional = "HH:mm:ss.SSS"
    case timeSeconds = "HH:mm:ss"
    case time = "HH:mm"
    case yearMonth = "yyyy-MM"
    case year = "yyyy"

    // MARK: Internal

    var hasDate: Bool {
      rawValue.contains("yyyy-MM-dd")
    }

    var hasTime: Bool {
      rawValue.contains("HH:mm")
    }

    var hasSeconds: Bool {
      rawValue.contains("ss")
    }

    var hasTimeZone: Bool {
      rawValue.contains("Z")
    }
  }

  let normalizedDate: String
  let format: Format
}
