import BITAnyCredentialFormat
import BITCore
import Foundation
import Spyable

// MARK: - ValueTypeResolverProtocol

@Spyable
protocol ValueTypeResolverProtocol {
  func callAsFunction(_ anyClaim: AnyClaim) -> ValueType?
}

// MARK: - ValueTypeResolver

struct ValueTypeResolver: ValueTypeResolverProtocol {

  // MARK: Internal

  func callAsFunction(_ anyClaim: AnyClaim) -> ValueType? {
    guard let value = anyClaim.value else { return nil }

    return switch value {
    case .bool:
      .boolean
    case .double,
         .int:
      .numeric
    case .string(let stringValue):
      parseDataURL(stringValue) ?? parseDate(stringValue) ?? parseBase64Image(stringValue) ?? .string
    case .array,
         .dictionary:
      .string
    }
  }

  // MARK: Private

  private func parseDataURL(_ value: String) -> ValueType? {
    guard
      let url = URL(string: value),
      url.dataURLDataString != nil,
      let mediaType = url.mediaType,
      let valueType = ValueType(rawValue: mediaType),
      valueType.isImage
    else {
      return nil
    }

    return valueType
  }

  private func parseBase64Image(_ value: String) -> ValueType? {
    guard let data = Data(base64Encoded: value)
    else {
      return nil
    }

    return ValueType.allCases.first { $0.isImage && $0.matchesByteSignature(of: data) }
  }

  private func parseDate(_ value: String) -> ValueType? {
    let formatter = DateFormatter()

    for format in DateParserResult.Format.allCases {
      formatter.dateFormat = format.rawValue
      if formatter.date(from: value) != nil {
        return .dateTime
      }
    }

    return nil
  }
}
