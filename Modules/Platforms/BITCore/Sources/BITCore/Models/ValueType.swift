import Foundation

// MARK: - ValueType

public enum ValueType: String, Codable, CaseIterable {
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

  public var byteSignature: [UInt8]? {
    switch self {
    case .imageJpg:
      [0xFF, 0xD8, 0xFF]
    case .imagePng:
      [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    default:
      nil
    }
  }

  public func matchesByteSignature(of data: Data) -> Bool {
    guard let byteSignature, data.count >= 12 else {
      return false
    }

    let magicBytes = [UInt8](data.prefix(12))
    return magicBytes.starts(with: byteSignature)
  }
}
