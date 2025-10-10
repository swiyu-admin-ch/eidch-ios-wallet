import Factory
import Foundation

public typealias AttributeKey = String
public typealias Locale = String
public typealias DataSourceFormat = String

// MARK: - OcaBundle

/// Represents an OCA Bundle that contains Capture Bases and Overlays associated with a data source.
public struct OcaBundle {

  // MARK: Lifecycle

  init(captureBases: [any CaptureBase], overlays: [any Overlay]) throws {
    self.captureBases = captureBases
    self.overlays = overlays

    try ocaBundleValidator.validate(captureBases, overlays)
    attributes = overlayBundleAttributeGenerator.generate(from: self)
  }

  // MARK: Public

  public let captureBases: [any CaptureBase]
  public let overlays: [any Overlay]

  public var rootCaptureBaseDigest: String {
    (try? rootResolver.resolve(captureBases).digest) ?? ""
  }

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
  public func getAttributeForJsonPath(jsonPath: JsonPath) -> OverlayBundleAttribute? {
    getAttributes().first { attribute in
      attribute.dataSources.values.contains { $0 == jsonPath }
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

  private var attributes = [OverlayBundleAttribute]()
  @Injected(\.overlayBundleAttributesGenerator) private var overlayBundleAttributeGenerator: OverlayBundleAttributesGeneratorProtocol
  @Injected(\.ocaBundleValidator) private var ocaBundleValidator: OcaBundleValidatorProtocol
  @Injected(\.rootCaptureBaseResolver) private var rootResolver: RootCaptureBaseResolverProtocol

  private func getLatestOverlaySpecType(for type: OverlayType, digest: String? = nil) -> OverlaySpecType? {
    let overlayTypes = getOverlays(digest: digest).map(\.type)
    return type.getSpecTypes().first { overlayTypes.contains($0) }
  }

  private func getOverlays(digest: String? = nil) -> [any Overlay] {
    overlays.filter { digest == nil || $0.captureBaseDigest == digest }
  }
}
