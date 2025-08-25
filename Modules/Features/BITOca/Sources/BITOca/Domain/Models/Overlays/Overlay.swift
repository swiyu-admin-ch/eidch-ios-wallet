// MARK: - Overlay

public protocol Overlay: Decodable, Equatable {
  var type: OverlaySpecType { get }
  var captureBaseDigest: String { get }

  func validate(with captureBases: [any CaptureBase], overlays: [any Overlay]) throws
}

extension Overlay {
  public func validate(with captureBases: [any CaptureBase], overlays: [any Overlay]) throws {}
}
