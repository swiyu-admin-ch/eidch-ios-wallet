import BITL10n
import Foundation
import UIKit

// MARK: - BITAppearance

public class BITAppearance {

  public static func setup() {
    registerFonts()
    setUIViewAppearance()
    setUILabels()
    setUISearchBar()
    setNavigationTitleAppearance()
    setDefaultNavigationAppearance(.default)
  }

}

extension BITAppearance {

  // MARK: Public

  public static func setDefaultNavigationAppearance(_ appearance: UINavigationBarAppearance) {
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
  }

  // MARK: Private

  private static func registerFonts() {
    FontFamily.registerAllCustomFonts()
  }

  private static func setUIViewAppearance() {
    let appearance = UIView.appearance()
    appearance.tintColor = ThemingAssets.accentColor.color
  }

  private static func setUILabels() {
    let headerLabels = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
    headerLabels.font = UIFont.preferredFont(forTextStyle: .callout, font: FontFamily.ABCDiatype.regular)
  }

  private static func setUISearchBar() {
    let searchBarAppeareance = UISearchBar.appearance()
    searchBarAppeareance.tintColor = ThemingAssets.accentColor.color
    searchBarAppeareance.searchBarStyle = .default
  }

  private static func setNavigationTitleAppearance() {
    let inlineTitleTextAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body, font: FontFamily.ABCDiatype.bold)]
    let largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle, font: FontFamily.ABCDiatype.bold)]

    UINavigationBar.appearance().titleTextAttributes = inlineTitleTextAttributes
    UINavigationBar.appearance().largeTitleTextAttributes = largeTitleTextAttributes
    UINavigationBar.appearance().prefersLargeTitles = false
  }

}
