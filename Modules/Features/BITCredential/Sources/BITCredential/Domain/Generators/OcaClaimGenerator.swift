import BITAnyCredentialFormat
import BITCore
import BITCredentialShared
import BITCrypto
import BITOca
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - OcaClaimGeneratorProtocol

@Spyable
protocol OcaClaimGeneratorProtocol {
  func generate(for anyClaim: AnyClaim, ocaAttribute: OverlayBundleAttribute) -> CredentialClaim
}

// MARK: - OcaClaimGenerator

struct OcaClaimGenerator: OcaClaimGeneratorProtocol {

  // MARK: Internal

  func generate(for anyClaim: AnyClaim, ocaAttribute: OverlayBundleAttribute) -> CredentialClaim {
    var value = anyClaim.value?.rawValue
    var valueType: ValueType?
    var valueDisplayInfo: String?
    if ocaAttribute.standard == .dataURLScheme, let dataUrl = value, let (type, dataString) = parseDataURL(dataUrl) {
      value = dataString
      valueType = type
    } else if ocaAttribute.attributeType == .dateTime {
      let result = value.flatMap { overlayAttributeDateParser.parse($0, with: ocaAttribute) }
      value = result?.normalizedDate ?? value
      valueDisplayInfo = result?.format.rawValue
      valueType = .dateTime
    }
    return CredentialClaim(
      key: anyClaim.key.replacing("$.", with: ""),
      value: value,
      valueType: valueType?.rawValue ?? ValueType(ocaAttribute).rawValue,
      valueDisplayInfo: valueDisplayInfo,
      order: ocaAttribute.order ?? Int(Int16.max),
      displays: createClaimDisplays(from: ocaAttribute, value: value))
  }

  // MARK: Private

  @Injected(\.overlayAttributeDateParser) private var overlayAttributeDateParser: OverlayAttributeDateParserProtocol

  private func parseDataURL(_ string: String) -> (ValueType, String)? {
    if
      let url = URL(string: string),
      let dataString = url.dataURLDataString,
      let mediaType = url.mediaType,
      let type = ValueType(rawValue: mediaType)
    {
      return (type, dataString)
    }
    return nil
  }

  private func createClaimDisplays(from ocaAttribute: OverlayBundleAttribute, value: String?) -> [CredentialClaimDisplay] {
    let displays = ocaAttribute.labels.map { locale, label in
      let entries = ocaAttribute.entryMapping.first { $0.key == locale }?.value ?? [:]
      let localizedValue = entries.first { $0.key == value }?.value
      return CredentialClaimDisplay(locale: locale, name: label, value: localizedValue)
    }
    guard let value else { return displays }
    let locales = displays.map(\.locale)
    let missedEntries = ocaAttribute.entryMapping.filter { !locales.contains($0.key) }
    let entriesOnlyDisplays = createClaimDisplays(for: missedEntries, value: value)
    return displays + entriesOnlyDisplays
  }

  private func createClaimDisplays(for entryMapping: [BITOca.Locale: [EntryCode: String]], value: String) -> [CredentialClaimDisplay] {
    entryMapping.compactMap { locale, entryMapping in
      guard let entry = entryMapping.first(where: { $0.key == value }) else { return nil }
      return CredentialClaimDisplay(locale: locale, name: nil, value: entry.value)
    }
  }
}

extension ValueType {

  // MARK: Lifecycle

  init(_ attribute: OverlayBundleAttribute) {
    self = switch attribute.attributeType {
    case .binary:
      Self.getValueTypeForBinaryAttribute(attribute)
    case .boolean:
      .boolean
    case .dateTime:
      .dateTime
    case .numeric:
      .numeric
    case .text:
      .string
    case .array,
         .reference:
      .string
    }
  }

  // MARK: Private

  private static func getValueTypeForBinaryAttribute(_ attribute: OverlayBundleAttribute) -> ValueType {
    guard attribute.characterEncoding == .base64 else { return .string }
    return switch attribute.format {
    case ValueType.imagePng.rawValue:
      .imagePng
    case ValueType.imageJpg.rawValue:
      .imageJpg
    default:
      .string
    }
  }
}
