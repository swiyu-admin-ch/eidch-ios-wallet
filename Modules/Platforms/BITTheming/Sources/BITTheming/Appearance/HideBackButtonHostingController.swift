import SwiftUI

public class HideBackButtonHostingController<Content: View>: UIHostingController<Content> {

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.setHidesBackButton(true, animated: false)
  }
}
