import BITAnalytics
import Factory
import Foundation

public typealias AttributeKey = String
public typealias Locale = String
public typealias DataSourceFormat = String
public typealias JsonPath = String

// MARK: - OcaBundle

/// Represents an OCA Bundle that contains Capture Bases and Overlays associated with a data source.
public struct OcaBundle: Decodable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let captureBases = try container.decode([TypeDecodedCaptureBase].self, forKey: .captureBases)
      .compactMap(\.captureBase)
    let overlays = try container.decode([TypeDecodedOverlay].self, forKey: .overlays)
      .compactMap(\.overlay)
    self.init(captureBases: captureBases, overlays: overlays)
  }

  init(captureBases: [any CaptureBase], overlays: [any Overlay]) {
    self.captureBases = captureBases
    self.overlays = overlays
    attributes = parseAttributes(from: captureBases, using: overlays)
  }

  // MARK: Public

  public let captureBases: [any CaptureBase]
  public let overlays: [any Overlay]

  /// Retrieves all Overlay Bundle attributes of the Capture Base.
  /// - Parameter digest: An optional CESR digest of the associated Capture Base.
  /// - Returns: A list of `OverlayBundleAttribute` objects.
  public func getAttributes(digest: String? = nil) -> [OverlayBundleAttribute] {
    if let digest {
      attributes.filter { $0.captureBaseDigest == digest }
    } else {
      attributes
    }
  }

  /// Retrieves OverlayBundleAttribute associated to the given JSONPath.
  /// - Parameters:
  ///   - jsonPath: JSONPath
  /// - Returns: The capture Base attribute associated `OverlayBundleAttribute`.
  public func getAttributeForJsonPath(jsonPath: String) -> OverlayBundleAttribute? {
    getAttributes().first { attribute in
      attribute.dataSources.values.contains { attributeJsonPath in
        jsonPath == attributeJsonPath || attributeJsonPath.validate(jsonPath)
      }
    }
  }

  public func getLatestOverlaysOfType(overlayType: OverlayType, digest: String? = nil) -> [any Overlay] {
    let specType = getLatestOverlaySpecType(for: overlayType, digest: digest)
    return getOverlays(digest: digest).filter { $0.type == specType }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case captureBases = "capture_bases"
    case overlays
  }

  // MARK: Private

  private var attributes: [OverlayBundleAttribute] = []
  @Injected(\.analytics) private var analytics: AnalyticsProtocol

  private func getLatestOverlaySpecType(for type: OverlayType, digest: String? = nil) -> OverlaySpecType? {
    let overlayTypes = getOverlays(digest: digest).map(\.type)
    return type.getSpecTypes().first { overlayTypes.contains($0) }
  }

  private func getOverlays(digest: String? = nil) -> [any Overlay] {
    if let digest {
      overlays.filter { $0.captureBaseDigest == digest }
    } else {
      overlays
    }
  }

  private func parseAttributes(from captureBases: [any CaptureBase], using overlays: [any Overlay]) -> [OverlayBundleAttribute] {
    captureBases.flatMap { base in
      let labelsByAttribute = getLabelsForAttributes(for: base)
      let dataSourcesByAttribute = getDataSourcesForAttributes(for: base)
      return base.attributes.map { attribute in
        OverlayBundleAttribute(
          captureBaseDigest: base.digest,
          name: attribute.key,
          attributeType: attribute.value,
          labels: labelsByAttribute[attribute.key] ?? [:],
          dataSources: dataSourcesByAttribute[attribute.key] ?? [:])
      }
    }
  }

  private func getLabelsForAttributes(for base: any CaptureBase) -> [AttributeKey: [Locale: String]] {
    let labelOverlays = getLatestOverlaysOfType(overlayType: .label, digest: base.digest)
      .compactMap { $0 as? any LabelOverlay }
    let attributes = base.attributes.map(\.key)
    let labels = attributes.compactGroupWith { attribute in
      labelOverlays.compactGroup(keySelector: \.language, valueTransform: { overlay in
        overlay.attributeLabels[attribute]
      })
    }
    if labels.first(where: { labelOverlays.count > $0.value.count }) != nil {
      analytics.log(AnalyticsEvent.duplicateInLabelOverlays)
    }
    return labels
  }

  private func getDataSourcesForAttributes(for base: any CaptureBase) -> [AttributeKey: [DataSourceFormat: JsonPath]] {
    let dataSourceOverlays = getLatestOverlaysOfType(overlayType: .dataSource, digest: base.digest)
      .compactMap { $0 as? any DataSourceOverlay }
    let attributes = base.attributes.map(\.key)
    let dataSources = attributes.compactGroupWith { attribute in
      dataSourceOverlays.compactGroup(keySelector: \.format, valueTransform: { overlay in
        overlay.attributeSources[attribute]
      })
    }
    if dataSources.first(where: { dataSourceOverlays.count > $0.value.count }) != nil {
      analytics.log(AnalyticsEvent.duplicateInDataSourceOverlays)
    }
    return dataSources
  }

}

// MARK: OcaBundle.AnalyticsEvent

extension OcaBundle {
  enum AnalyticsEvent: AnalyticsEventProtocol {
    case duplicateInDataSourceOverlays
    case duplicateInLabelOverlays
  }
}
