import BITL10n
import Foundation
import UIKit

extension UINavigationBarAppearance {

  public static var login: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()

    appearance.configureWithTransparentBackground()
    appearance.backButtonAppearance = UIBarButtonItemAppearance(style: .plain)

    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

    let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
    barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.white]
    barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.white]
    barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]

    let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]

    appearance.buttonAppearance = barButtonItemAppearance
    appearance.backButtonAppearance = backButtonAppearance
    appearance.doneButtonAppearance = barButtonItemAppearance

    let backButtonImage = ThemingAssets.backIndicatorBackgroundDark.image
    let insets = UIEdgeInsets(top: 0, left: -.x3, bottom: 1, right: 0)
    let backImage = ThemingAssets.backIndicatorDark.image.withAlignmentRectInsets(insets)
    backImage.accessibilityLabel = L10n.globalBack

    appearance.backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

    appearance.backButtonAppearance.normal.backgroundImage = backButtonImage
    appearance.backButtonAppearance.focused.backgroundImage = backButtonImage
    appearance.backButtonAppearance.highlighted.backgroundImage = backButtonImage
    appearance.backButtonAppearance.disabled.backgroundImage = backButtonImage

    UIBarButtonItem.appearance().tintColor = .white

    return appearance
  }

  public static var `default`: UINavigationBarAppearance {
    let backButtonImage = ThemingAssets.backIndicatorBackground.image
    let insets = UIEdgeInsets(top: 0, left: -.x3, bottom: 1, right: 0)
    let backImage = ThemingAssets.backIndicator.image.withAlignmentRectInsets(insets)
    backImage.accessibilityLabel = L10n.globalBack

    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()

    appearance.shadowColor = .clear

    appearance.backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

    let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
    barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]

    let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]

    appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    appearance.buttonAppearance = barButtonItemAppearance
    appearance.backButtonAppearance = backButtonAppearance
    appearance.doneButtonAppearance = barButtonItemAppearance

    appearance.backButtonAppearance.normal.backgroundImage = backButtonImage
    appearance.backButtonAppearance.focused.backgroundImage = backButtonImage
    appearance.backButtonAppearance.highlighted.backgroundImage = backButtonImage
    appearance.backButtonAppearance.disabled.backgroundImage = backButtonImage

    UIBarButtonItem.appearance().tintColor = ThemingAssets.navigationAccent.color

    return appearance
  }

  public static var defaultTransparent: UINavigationBarAppearance {
    let backButtonImage = ThemingAssets.backIndicatorBackground.image
    let insets = UIEdgeInsets(top: 0, left: -.x3, bottom: 1, right: 0)
    let backImage = ThemingAssets.backIndicator.image.withAlignmentRectInsets(insets)
    backImage.accessibilityLabel = L10n.globalBack

    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()

    appearance.backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

    let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
    barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]
    barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: ThemingAssets.accentColor.color]

    let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]

    appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    appearance.buttonAppearance = barButtonItemAppearance
    appearance.backButtonAppearance = backButtonAppearance
    appearance.doneButtonAppearance = barButtonItemAppearance

    appearance.backButtonAppearance.normal.backgroundImage = backButtonImage
    appearance.backButtonAppearance.focused.backgroundImage = backButtonImage
    appearance.backButtonAppearance.highlighted.backgroundImage = backButtonImage
    appearance.backButtonAppearance.disabled.backgroundImage = backButtonImage

    UIBarButtonItem.appearance().tintColor = ThemingAssets.navigationAccent.color

    return appearance
  }

}
