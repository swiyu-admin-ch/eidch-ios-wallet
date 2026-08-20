import BITTheming
import SwiftUI

// MARK: - LoginHostingController

public class LoginHostingController<Content: View>: UIHostingController<Content> {

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    applyNavigationAppearance(.login, tintColor: .white)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    applyNavigationAppearance(.default)
  }

}
