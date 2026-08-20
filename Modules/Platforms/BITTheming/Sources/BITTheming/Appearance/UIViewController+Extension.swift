import Foundation
import UIKit

extension UIViewController {

  public func applyNavigationAppearance(
    _ appearance: UINavigationBarAppearance,
    scrollEdgeAppearance: UINavigationBarAppearance? = nil,
    tintColor: UIColor = ThemingAssets.navigationAccent.color)
  {
    navigationController?.navigationBar.standardAppearance = appearance
    navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
    navigationController?.navigationBar.compactAppearance = appearance
    navigationController?.navigationBar.compactScrollEdgeAppearance = scrollEdgeAppearance
    navigationController?.navigationBar.tintColor = tintColor
  }

}
