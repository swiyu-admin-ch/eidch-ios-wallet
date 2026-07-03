import BITClaimsPathPointer
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
  func generate(path: ClaimsPathPointer, value: String?, ocaAttribute: OverlayBundleAttribute?, order: Int?) throws -> CredentialClaim
}

// MARK: - OcaClaimGenerator

struct OcaClaimGenerator: OcaClaimGeneratorProtocol {

  // MARK: Internal

  func generate(path: ClaimsPathPointer, value: String?, ocaAttribute: OverlayBundleAttribute?, order: Int?) throws -> CredentialClaim {
    var value = value
    var valueType: ValueType?
    var valueDisplayInfo: String?
    if ocaAttribute?.standard == .dataURLScheme, let dataUrl = value, let (type, dataString) = parseDataURL(dataUrl) {
      value = dataString
      valueType = type
    } else if ocaAttribute?.attributeType == .dateTime, let ocaAttribute {
      let result = value.flatMap { overlayAttributeDateParser.parse($0, with: ocaAttribute) }
      value = result?.normalizedDate ?? value
      valueDisplayInfo = result?.format.rawValue
      valueType = .dateTime
    }

    let finalValueType = valueType ?? ocaAttribute.map(ValueType.init) ?? .string

    if finalValueType.isImage, let value {
      try imageValidator.validate(base64Image: value, against: finalValueType)
    }

    return CredentialClaim(
      path: path,
      value: value,
      valueType: finalValueType.rawValue,
      valueDisplayInfo: valueDisplayInfo,
      order: order ?? ocaAttribute?.order ?? Int(Int16.max),
      isSensitive: ocaAttribute?.isSensitive ?? false,
      displays: ocaAttribute.map { createClaimDisplays(from: $0, value: value) } ?? [])
  }

  // MARK: Private

  @Injected(\.imageValidator) private var imageValidator: ImageValidatorProtocol
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
    let displays: [CredentialClaimDisplay] = ocaAttribute.labels.map { locale, label in
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
