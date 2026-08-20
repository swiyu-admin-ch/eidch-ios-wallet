import BITTheming
import Foundation
import SwiftUI
import UIKit

// MARK: - PinCodeInformationController

class PinCodeInformationController: UIHostingController<PinCodeInformationView> {}

// MARK: - PinCodeHostingController

class PinCodeHostingController<Content: View>: UIHostingController<Content> {

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    applyNavigationAppearance(.login, tintColor: .white)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    applyNavigationAppearance(.defaultTransparent)
  }
}
