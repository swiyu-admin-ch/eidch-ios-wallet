import Foundation

// MARK: - ValueType

public enum ValueType: String, Codable {
  case boolean
  case dateTime
  case imagePng = "image/png"
  case imageJpg = "image/jpeg"
  case numeric
  case string
}

extension ValueType {
  public var isImage: Bool {
    switch self {
    case .imageJpg,
         .imagePng:
      true
    default:
      false
    }
  }
}

extension ValueType {
  public static var supportedImageTypes: [ValueType] {
    [.imageJpg, .imagePng]
  }
}
