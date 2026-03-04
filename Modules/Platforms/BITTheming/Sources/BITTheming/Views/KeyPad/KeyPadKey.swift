import BITL10n
import SwiftUI

public enum KeyPadKey: String, Identifiable {
  case none, zero, one, two, three, four, five, six,
       seven, eight, nine, delete, faceId, cancel

  // MARK: Public

  public var value: String? {
    switch self {
    case .none: ""
    case .zero: "0"
    case .one: "1"
    case .two: "2"
    case .three: "3"
    case .four: "4"
    case .five: "5"
    case .six: "6"
    case .seven: "7"
    case .eight: "8"
    case .nine: "9"
    case .delete,
         .faceId:
      nil
    case .cancel: L10n.globalCancel
    }
  }

  public var image: Image? {
    switch self {
    case .faceId: Image(systemName: "faceid")
    case .delete: Image(systemName: "delete.backward")
    default: nil
    }
  }

  public var font: SwiftUI.Font? {
    switch self {
    case .cancel: .body
    default: nil
    }
  }

  public var id: String {
    rawValue
  }
}
