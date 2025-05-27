// swiftlint:disable type_name

// MARK: - CaptureBase

/// Capture Base object, representing structural characteristics of a dataset.
///
/// https://oca.colossi.network/specification/#capture-base
public protocol CaptureBase: Decodable, Equatable {
  var type: CaptureBaseSpecType { get }
  var digest: String { get }
  var attributes: [String: AttributeType] { get }
}

// MARK: - CaptureBaseSpecType

/// Enum representing the different types of Capture Base specifications.
public enum CaptureBaseSpecType: String, Decodable {
  case base1_0 = "spec/capture_base/1.0"
}

// swiftlint:enable all
