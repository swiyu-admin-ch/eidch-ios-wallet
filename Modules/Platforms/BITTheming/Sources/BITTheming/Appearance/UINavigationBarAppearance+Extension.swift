import BITL10n
import Foundation
import UIKit

extension UINavigationBarAppearance {

  // MARK: Public

  public static var login: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.buttonAppearance = whiteBarButtonItemAppearance()
    appearance.doneButtonAppearance = whiteBarButtonItemAppearance()

    configureBackButton(appearance, isDark: true)

    UIBarButtonItem.appearance().tintColor = .white

    return appearance
  }

  public static var `default`: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.shadowColor = .clear
    appearance.buttonAppearance = defaultBarButtonItemAppearance()
    appearance.doneButtonAppearance = defaultBarButtonItemAppearance()

    configureBackButton(appearance)

    UIBarButtonItem.appearance().tintColor = ThemingAssets.navigationAccent.color

    return appearance
  }

  public static var secondary: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = ThemingAssets.Background.secondary.color
    appearance.shadowColor = .clear
    appearance.buttonAppearance = defaultBarButtonItemAppearance()
    appearance.doneButtonAppearance = defaultBarButtonItemAppearance()

    configureBackButton(appearance)

    UIBarButtonItem.appearance().tintColor = ThemingAssets.navigationAccent.color

    return appearance
  }

  public static var secondaryScroll: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = ThemingAssets.Background.groupedRow.color
    appearance.shadowColor = ThemingAssets.Label.secondary.color
    appearance.buttonAppearance = defaultBarButtonItemAppearance()
    appearance.doneButtonAppearance = defaultBarButtonItemAppearance()

    configureBackButton(appearance)

    UIBarButtonItem.appearance().tintColor = ThemingAssets.navigationAccent.color

    return appearance
  }

  public static var defaultTransparent: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.buttonAppearance = defaultBarButtonItemAppearance()
    appearance.doneButtonAppearance = defaultBarButtonItemAppearance()

    configureBackButton(appearance)

    UIBarButtonItem.appearance().tintColor = ThemingAssets.navigationAccent.color

    return appearance
  }

  // MARK: Private

  private static func defaultBarButtonItemAppearance() -> UIBarButtonItemAppearance {
    let appearance = UIBarButtonItemAppearance(style: .plain)
    appearance.normal.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    appearance.disabled.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    appearance.highlighted.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    appearance.focused.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    return appearance
  }

  private static func whiteBarButtonItemAppearance() -> UIBarButtonItemAppearance {
    let appearance = UIBarButtonItemAppearance(style: .plain)
    appearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]
    return appearance
  }

  private static func configureBackButton(_ appearance: UINavigationBarAppearance, isDark: Bool = false) {
    // title
    let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
    appearance.backButtonAppearance = backButtonAppearance

    // image
    let backButtonImage = isDark ?
      ThemingAssets.backIndicatorBackgroundDark.image :
      ThemingAssets.backIndicatorBackground.image
    let insets = UIEdgeInsets(top: 0, left: -.x3, bottom: 1, right: 0)
    let backImage = isDark ? ThemingAssets.backIndicatorDark.image : ThemingAssets.backIndicator.image
    let insettedImage = backImage.withAlignmentRectInsets(insets)
    insettedImage.accessibilityLabel = L10n.globalBack

    appearance.setBackIndicatorImage(insettedImage, transitionMaskImage: insettedImage)
    appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    appearance.backButtonAppearance.normal.backgroundImage = backButtonImage
    appearance.backButtonAppearance.focused.backgroundImage = backButtonImage
    appearance.backButtonAppearance.highlighted.backgroundImage = backButtonImage
    appearance.backButtonAppearance.disabled.backgroundImage = backButtonImage
  }
}
