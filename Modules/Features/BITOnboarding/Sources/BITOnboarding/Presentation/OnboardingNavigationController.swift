import Foundation
import UIKit

final class OnboardingNavigationController: UINavigationController {

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let appearance = UINavigationBarAppearance.defaultTransparent
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.compactAppearance = appearance
    navigationBar.compactScrollEdgeAppearance = appearance
  }

}
