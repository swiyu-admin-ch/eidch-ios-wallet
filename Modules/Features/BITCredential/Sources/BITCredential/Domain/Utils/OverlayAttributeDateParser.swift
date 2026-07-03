import BITCore
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

    for format in DateFormat.allCases {
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

  let normalizedDate: String
  let format: DateFormat
}
