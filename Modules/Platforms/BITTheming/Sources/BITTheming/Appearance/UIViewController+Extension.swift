import Foundation
import UIKit

extension UIViewController {

  public func applyNavigationAppearance(_ appearance: UINavigationBarAppearance, scrollEdgeAppearance: UINavigationBarAppearance? = nil) {
    navigationController?.navigationBar.standardAppearance = appearance
    navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
    navigationController?.navigationBar.compactAppearance = appearance
    navigationController?.navigationBar.compactScrollEdgeAppearance = scrollEdgeAppearance
  }

}
