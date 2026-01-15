import Foundation
import SwiftUI
import UIKit

extension Color {

  // MARK: Public

  public func suggestedColorScheme() -> ColorScheme? {
    let white = Color.white
    let black = Color.black

    guard
      let contrastWithWhite = contrastRatio(with: white),
      let contrastWithBlack = contrastRatio(with: black) else
    {
      return nil
    }

    return contrastWithWhite > contrastWithBlack ? .dark : .light
  }

  // MARK: Internal

  typealias SRGB = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

  // MARK: Private

  private func contrastRatio(with color: Color) -> CGFloat? {
    guard
      let currentColorComponents = getSRGBComponents(),
      let colorComponents = color.getSRGBComponents() else
    {
      return nil
    }

    ///
    /// Compute perceived brightness difference
    /// https://www.w3.org/TR/AERT/#color-contrast
    ///
    let brightness1 = (0.299 * currentColorComponents.red + 0.587 * currentColorComponents.green + 0.114 * currentColorComponents.blue)
    let brightness2 = (0.299 * colorComponents.red + 0.587 * colorComponents.green + 0.114 * colorComponents.blue)

    let brightnessDifference = abs(brightness1 - brightness2)

    let redDifference = abs(currentColorComponents.red - colorComponents.red)
    let greenDifference = abs(currentColorComponents.green - colorComponents.green)
    let blueDifference = abs(currentColorComponents.blue - colorComponents.blue)

    let colorDifference = redDifference + greenDifference + blueDifference

    return brightnessDifference + colorDifference
  }

  private func getSRGBComponents() -> SRGB? {
    let uiColor = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
    return (red, green, blue, alpha)
  }

}
