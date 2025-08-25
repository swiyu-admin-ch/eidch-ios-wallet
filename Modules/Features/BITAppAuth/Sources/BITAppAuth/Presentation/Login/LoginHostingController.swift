import BITTheming
import SwiftUI

// MARK: - LoginHostingController

public class LoginHostingController<Content>: UIHostingController<Content> where Content: View {

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    applyNavigationAppearance(.login)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    applyNavigationAppearance(.default)
  }

}
