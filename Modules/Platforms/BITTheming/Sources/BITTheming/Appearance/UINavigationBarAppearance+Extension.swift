import Foundation
import UIKit

extension UINavigationBarAppearance {

  // MARK: Public

  public static var login: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.buttonAppearance = barButtonItemAppearance(.white)
    appearance.doneButtonAppearance = barButtonItemAppearance(.white)

    return appearance
  }

  public static var `default`: UINavigationBarAppearance {
    branded { $0.configureWithDefaultBackground() }
  }

  public static var secondary: UINavigationBarAppearance {
    branded { $0.configureWithDefaultBackground() }
  }

  public static var secondaryScroll: UINavigationBarAppearance {
    branded { $0.configureWithDefaultBackground() }
  }

  public static var defaultTransparent: UINavigationBarAppearance {
    branded { $0.configureWithTransparentBackground() }
  }

  // MARK: Private

  private static func branded(_ configure: (UINavigationBarAppearance) -> Void) -> UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    configure(appearance)
    appearance.shadowColor = .clear
    appearance.buttonAppearance = barButtonItemAppearance(ThemingAssets.accentColor.color)
    appearance.doneButtonAppearance = barButtonItemAppearance(ThemingAssets.accentColor.color)

    return appearance
  }

  private static func barButtonItemAppearance(_ color: UIColor) -> UIBarButtonItemAppearance {
    let appearance = UIBarButtonItemAppearance(style: .plain)
    appearance.normal.titleTextAttributes = [.foregroundColor: color]
    appearance.disabled.titleTextAttributes = [.foregroundColor: color]
    appearance.highlighted.titleTextAttributes = [.foregroundColor: color]
    appearance.focused.titleTextAttributes = [.foregroundColor: color]
    return appearance
  }
}
