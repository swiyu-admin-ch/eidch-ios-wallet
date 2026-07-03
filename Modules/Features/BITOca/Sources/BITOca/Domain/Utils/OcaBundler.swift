import Factory
import Foundation
import Spyable

// MARK: - OcaBundlerProtocol

///
/// Providing functionality for working with OCA (Overlays Capture Base)
/// https://github.com/e-id-admin/open-source-community/blob/main/tech-roadmap/rfcs/oca/spec.md
///
@Spyable
public protocol OcaBundlerProtocol {
  ///
  /// Validates a OCA Bundle JSON and creates the [OcaBundle] data model.
  ///
  /// @param data The JSON string representing an OCA Bundle.
  /// @return The [OcaBundle] data model.
  /// @throws OcaError if validation or creation of OCA Bundle fails.
  func createOcaBundle(_ data: Data) throws -> OcaBundle
}

// MARK: - OcaBundler

struct OcaBundler: OcaBundlerProtocol {

  // MARK: Internal

  func createOcaBundle(_ data: Data) throws -> OcaBundle {
    guard digestsValidator.validate(data) else { throw OcaError.invalidCESRHash }

    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw OcaError.invalidJsonObject
    }

    let captureBases = try decodeCaptureBases(json)
    let overlays = try templateResolver(overlays: decodeOverlays(json))

    return try OcaBundle(captureBases: captureBases, overlays: overlays)
  }

  // MARK: Private

  @Injected(\.ocaCaptureBaseDigestsValidator) private var digestsValidator
  @Injected(\.overlayTemplateResolver) private var templateResolver

  private func decodeCaptureBases(_ json: [String: Any]) throws -> [any CaptureBase] {
    guard let captureBasesJSON = json["capture_bases"] as? [[String: Any]] else {
      throw OcaError.invalidJsonObject
    }

    let captureBasesData = try JSONSerialization.data(withJSONObject: captureBasesJSON)
    return try JSONDecoder().decode([TypeDecodedCaptureBase].self, from: captureBasesData)
      .compactMap(\.captureBase)
  }

  private func decodeOverlays(_ json: [String: Any]) throws -> [any Overlay] {
    guard let overlaysJSON = json["overlays"] as? [[String: Any]] else {
      throw OcaError.invalidJsonObject
    }

    let overlaysData = try JSONSerialization.data(withJSONObject: overlaysJSON)
    return try JSONDecoder().decode([TypeDecodedOverlay].self, from: overlaysData)
      .compactMap((\.overlay))
  }

}
