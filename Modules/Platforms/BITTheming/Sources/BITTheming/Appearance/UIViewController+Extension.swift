import Foundation
import UIKit

extension UIViewController {

  public func applyNavigationAppearance(_ appearance: UINavigationBarAppearance) {
    navigationController?.navigationBar.standardAppearance = appearance
    navigationController?.navigationBar.scrollEdgeAppearance = appearance
    navigationController?.navigationBar.compactAppearance = appearance
    navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
  }

}
