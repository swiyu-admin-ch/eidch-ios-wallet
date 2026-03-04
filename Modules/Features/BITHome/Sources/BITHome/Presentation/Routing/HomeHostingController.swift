import SwiftUI
import UIKit

// MARK: - HomeHostingController

class HomeHostingController<Content: View>: UIHostingController<Content> {

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }

}
