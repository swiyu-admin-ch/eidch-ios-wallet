import SwiftUI

// MARK: - CustomButtonConfiguration

public struct CustomButtonConfiguration {

  // MARK: Lifecycle

  public init(
    foregroundColor: Color = .white,
    foregroundColorDisabled: Color = ThemingAssets.Label.tertiary.swiftUIColor,
    backgroundColor: Color = ThemingAssets.accentColor.swiftUIColor,
    backgroundColorDisabled: Color = ThemingAssets.petrol2.swiftUIColor,
    progressViewTint: Color = .white,
    isMaterialEnabled: Bool = false)
  {
    self.foregroundColor = foregroundColor
    self.foregroundColorDisabled = foregroundColorDisabled
    self.backgroundColor = backgroundColor
    self.backgroundColorDisabled = backgroundColorDisabled
    self.progressViewTint = progressViewTint
    self.isMaterialEnabled = isMaterialEnabled
  }

  // MARK: Internal

  var foregroundColor: Color = ThemingAssets.Label.primary.swiftUIColor
  var foregroundColorDisabled: Color = ThemingAssets.Label.tertiary.swiftUIColor
  var backgroundColor = Color.clear
  var backgroundColorDisabled = Color.clear
  var progressViewTint: Color = ThemingAssets.Label.primary.swiftUIColor
  var isMaterialEnabled = false
}

extension CustomButtonConfiguration {
  public static var primary = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor,
    backgroundColor: ThemingAssets.Brand.Core.navyBlue.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)

  public static var secondary = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Label.primary.swiftUIColor,
    backgroundColor: ThemingAssets.Background.Button.secondary.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.accentColor.swiftUIColor)

  public static var secondaryReversed = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor,
    foregroundColorDisabled: ThemingAssets.Brand.Core.navyBlue.swiftUIColor,
    backgroundColor: ThemingAssets.Grays.white.swiftUIColor,
    progressViewTint: ThemingAssets.Label.primary.swiftUIColor)

  public static var tertiary = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.firGreenLabel.swiftUIColor,
    backgroundColor: ThemingAssets.Brand.Core.firGreen.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.Brand.Core.firGreenLabel.swiftUIColor)

  public static var destructive = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor,
    backgroundColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor.opacity(0.2),
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.Brand.Core.swissRed.swiftUIColor)

  public static var bezeled = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor,
    backgroundColor: ThemingAssets.Brand.Shades.navyBlue70.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)

  public static var firGreen = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.firGreen.swiftUIColor,
    backgroundColor: ThemingAssets.Brand.Core.firGreenLabel.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.Brand.Core.firGreen.swiftUIColor)

  public static var navyBlue = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.navyBlue.swiftUIColor,
    backgroundColor: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
}
