import SwiftUI

extension DynamicTypeSize {
  public var isLargeAccessibilitySize: Bool {
    switch self {
    case .accessibility2,
         .accessibility3,
         .accessibility4,
         .accessibility5: true
    default: false
    }
  }
}
