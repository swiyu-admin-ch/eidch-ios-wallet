import Foundation
import SwiftUI
import UIKit

extension ColorScheme {

  // MARK: Public

  public var rawValue: String {
    switch self {
    case .light:
      return "light"
    case .dark:
      return "dark"
    @unknown default:
      return "light"
    }
  }

  public func standardColor() -> Color {
    self == .dark ? ThemingAssets.Grays.white.swiftUIColor : ThemingAssets.Grays.black.swiftUIColor
  }

  // MARK: Internal

  var userInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .dark: .dark
    case .light: .light
    @unknown default: .unspecified
    }
  }

}

extension ColorAsset {
  public var light: Color {
    color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
  }

  public var dark: Color {
    color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
  }
}
