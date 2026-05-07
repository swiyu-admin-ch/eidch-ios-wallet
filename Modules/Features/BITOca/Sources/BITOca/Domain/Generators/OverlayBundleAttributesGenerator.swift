import BITAnalytics
import BITClaimsPathPointer
import Factory
import Foundation
import Spyable

// MARK: - OverlayBundleAttributesGeneratorProtocol

@Spyable
public protocol OverlayBundleAttributesGeneratorProtocol {
  func generate(from ocaBundle: OcaBundle) -> [OverlayBundleAttribute]
}

// MARK: - OverlayBundleAttributesGenerator

struct OverlayBundleAttributesGenerator: OverlayBundleAttributesGeneratorProtocol {

  // MARK: Internal

  func generate(from ocaBundle: OcaBundle) -> [OverlayBundleAttribute] {
    ocaBundle.captureBases.flatMap { base in
      let encodingByAttribute = getEncodingForAttributes(for: base, ocaBundle: ocaBundle)
      let dataSourcesByAttribute = getDataSourcesForAttributes(for: base, ocaBundle: ocaBundle)
      let entryMappingByAttribute = getEntryMappingForAttributes(for: base, ocaBundle: ocaBundle)
      let formatByAttribute = getFormatForAttributes(for: base, ocaBundle: ocaBundle)
      let labelsByAttribute = getLabelsForAttributes(for: base, ocaBundle: ocaBundle)
      let orderByAttribute = getOrderForAttributes(for: base, ocaBundle: ocaBundle)
      let sensitiveAttributes = getSensitiveAttributes(for: base, ocaBundle: ocaBundle)
      let standardByAttribute = getStandardForAttributes(for: base, ocaBundle: ocaBundle)
      return base.attributes.map { attribute in
        OverlayBundleAttribute(
          captureBaseDigest: base.digest,
          name: attribute.key,
          attributeType: attribute.value,
          characterEncoding: encodingByAttribute[attribute.key],
          dataSources: dataSourcesByAttribute[attribute.key] ?? [:],
          entryMapping: entryMappingByAttribute[attribute.key] ?? [:],
          format: formatByAttribute[attribute.key],
          labels: labelsByAttribute[attribute.key] ?? [:],
          order: orderByAttribute[attribute.key],
          isSensitive: sensitiveAttributes.contains(attribute.key),
          standard: standardByAttribute[attribute.key])
      }
    }
  }

  // MARK: Private

  @Injected(\.analytics) private var analytics: AnalyticsProtocol

  private func getEncodingForAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey: CharacterEncoding] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .characterEncoding, digest: base.digest)
      .compactMap { $0 as? any CharacterEncodingOverlay }
    guard let overlay = overlays.first else { return [:] }
    if overlays.count > 1 {
      analytics.log(AnalyticsEvent.duplicateInCharacterEncodingOverlays)
    }
    let attributes = base.attributes.map(\.key)
    return attributes.compactGroupWith { attribute in
      overlay.attributeCharacterEncodings?[attribute] ?? overlay.defaultCharacterEncoding
    }
  }

  private func getDataSourcesForAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey: [DataSourceFormat: ClaimsPathPointer]] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .dataSource, digest: base.digest)
      .compactMap { $0 as? any DataSourceOverlay }
    let attributes = base.attributes.map(\.key)
    let dataSources = attributes.compactGroupWith { attribute in
      overlays.compactGroup(keySelector: \.format, valueTransform: { overlay in
        overlay.attributeSources[attribute]
      })
    }
    if dataSources.first(where: { overlays.count > $0.value.count }) != nil {
      analytics.log(AnalyticsEvent.duplicateInDataSourceOverlays)
    }
    return dataSources
  }

  private func getEntryMappingForAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey: [Locale: [EntryCode: String]]] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .entry, digest: base.digest)
      .compactMap { $0 as? any EntryOverlay }
    let attributes = base.attributes.map(\.key)
    let entries = attributes.compactGroupWith { attribute in
      overlays.compactGroup(keySelector: \.language, valueTransform: { overlay in
        overlay.attributeEntries[attribute]
      })
    }
    if entries.first(where: { overlays.count > $0.value.count }) != nil {
      analytics.log(AnalyticsEvent.duplicateInEntryOverlays)
    }
    return entries
  }

  private func getFormatForAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey: String] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .format, digest: base.digest)
      .compactMap { $0 as? any FormatOverlay }
    guard let overlay = overlays.first else { return [:] }
    if overlays.count > 1 {
      analytics.log(AnalyticsEvent.duplicateInFormatOverlays)
    }
    let attributes = base.attributes.map(\.key)
    return attributes.compactGroupWith { attribute in
      overlay.attributeFormats[attribute]
    }
  }

  private func getLabelsForAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey: [Locale: String]] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .label, digest: base.digest)
      .compactMap { $0 as? any LabelOverlay }
    let attributes = base.attributes.map(\.key)
    let labels = attributes.compactGroupWith { attribute in
      overlays.compactGroup(keySelector: \.language, valueTransform: { overlay in
        overlay.attributeLabels[attribute]
      })
    }
    if labels.first(where: { overlays.count > $0.value.count }) != nil {
      analytics.log(AnalyticsEvent.duplicateInLabelOverlays)
    }
    return labels
  }

  private func getOrderForAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey: Int] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .order, digest: base.digest)
      .compactMap { $0 as? any OrderOverlay }
    guard let overlay = overlays.first else { return [:] }
    if overlays.count > 1 {
      analytics.log(AnalyticsEvent.duplicateInOrderOverlays)
    }
    let attributes = base.attributes.map(\.key)
    return attributes.compactGroupWith { attribute in
      overlay.attributeOrders[attribute]
    }
  }

  private func getSensitiveAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .sensitive, digest: base.digest)
      .compactMap { $0 as? any SensitiveOverlay }
    guard let overlay = overlays.first else { return [] }
    if overlays.count > 1 {
      analytics.log(AnalyticsEvent.duplicateInSensitiveOverlays)
    }
    return overlay.attributes
  }

  private func getStandardForAttributes(for base: any CaptureBase, ocaBundle: OcaBundle) -> [AttributeKey: Standard] {
    let overlays = ocaBundle.getLatestOverlaysOfType(overlayType: .standard, digest: base.digest)
      .compactMap { $0 as? any StandardOverlay }
    guard let overlay = overlays.first else { return [:] }
    if overlays.count > 1 {
      analytics.log(AnalyticsEvent.duplicateInStandardOverlays)
    }
    let attributes = base.attributes.map(\.key)
    return attributes.compactGroupWith { attribute in
      overlay.attributeStandards[attribute]
    }
  }
}

// MARK: OverlayBundleAttributesGenerator.AnalyticsEvent

extension OverlayBundleAttributesGenerator {
  enum AnalyticsEvent: AnalyticsEventProtocol {
    case duplicateInCharacterEncodingOverlays
    case duplicateInDataSourceOverlays
    case duplicateInEntryOverlays
    case duplicateInFormatOverlays
    case duplicateInLabelOverlays
    case duplicateInOrderOverlays
    case duplicateInSensitiveOverlays
    case duplicateInStandardOverlays
  }
}
