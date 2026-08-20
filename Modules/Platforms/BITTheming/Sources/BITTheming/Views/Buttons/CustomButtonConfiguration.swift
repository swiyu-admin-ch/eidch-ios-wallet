import SwiftUI

// MARK: - CustomButtonConfiguration

public struct CustomButtonConfiguration {

  // MARK: Lifecycle

  public init(
    foregroundColor: Color = .white,
    foregroundColorDisabled: Color = ThemingAssets.Label.tertiary.swiftUIColor,
    backgroundColor: Color = ThemingAssets.accentColor.swiftUIColor,
    backgroundColorDisabled: Color = ThemingAssets.petrol2.swiftUIColor,
    borderColor: Color = .clear,
    borderWidth: CGFloat = 0,
    cornerRadius: CGFloat? = nil,
    progressViewTint: Color = .white,
    isMaterialEnabled: Bool = false)
  {
    self.foregroundColor = foregroundColor
    self.foregroundColorDisabled = foregroundColorDisabled
    self.backgroundColor = backgroundColor
    self.backgroundColorDisabled = backgroundColorDisabled
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.progressViewTint = progressViewTint
    self.isMaterialEnabled = isMaterialEnabled
  }

  // MARK: Internal

  var foregroundColor: Color = ThemingAssets.Label.primary.swiftUIColor
  var foregroundColorDisabled: Color = ThemingAssets.Label.tertiary.swiftUIColor
  var backgroundColor = Color.clear
  var backgroundColorDisabled = Color.clear
  var borderColor = Color.clear
  var borderWidth: CGFloat = 0
  var cornerRadius: CGFloat?
  var progressViewTint: Color = ThemingAssets.Label.primary.swiftUIColor
  var isMaterialEnabled = false
}

extension CustomButtonConfiguration {
  public static var primary = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor,
    backgroundColor: ThemingAssets.Brand.Core.navyBlue.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Background.Button.primaryDisabled.swiftUIColor,
    progressViewTint: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)

  public static var secondary = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Label.primary.swiftUIColor,
    backgroundColor: ThemingAssets.Background.Button.secondary.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    progressViewTint: ThemingAssets.accentColor.swiftUIColor)

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

  public static var warning = CustomButtonConfiguration(
    foregroundColor: ThemingAssets.Background.Button.warningLabel.swiftUIColor,
    backgroundColor: ThemingAssets.Background.Button.warning.swiftUIColor,
    backgroundColorDisabled: ThemingAssets.Fills.tertiary.swiftUIColor,
    borderColor: ThemingAssets.Background.Button.warningBorder.swiftUIColor,
    borderWidth: 1,
    cornerRadius: .x4,
    progressViewTint: ThemingAssets.Background.Button.warningLabel.swiftUIColor)
}
