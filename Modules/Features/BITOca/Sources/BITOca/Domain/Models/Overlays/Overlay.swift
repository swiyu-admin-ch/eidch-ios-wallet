// MARK: - Overlay

public protocol Overlay: Decodable, Equatable {
  var type: OverlaySpecType { get }
  var captureBaseDigest: String { get }
}
