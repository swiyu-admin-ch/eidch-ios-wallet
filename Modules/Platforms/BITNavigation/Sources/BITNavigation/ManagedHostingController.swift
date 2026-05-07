import NavigatorUI
import SwiftUI

/**
 * HostingController encapsulating a ManagedNavigationStack to create Views with NavigatorUI destinations
 */
public final class ManagedHostingController<Content: View>: UIHostingController<AnyView> {
  public init(@ViewBuilder _ content: @escaping () -> Content) {
    super.init(rootView: AnyView(ManagedNavigationStack { content() }))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
