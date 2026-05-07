import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - DefaultEidRequestToolbar

struct DefaultEidRequestToolbar: ViewModifier {

  // MARK: Lifecycle

  init(onClose: (() -> Void)? = nil) {
    self.onClose = onClose
  }

  // MARK: Internal

  func body(content: Content) -> some View {
    content
      .toolbar {
        CloseButtonToolbar {
          handleClose()

        }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator: Navigator

  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  private let onClose: (() -> Void)?

  private func handleClose() {
    onClose?()
    coordinator.cleanup()
    navigator.dismiss()
  }
}

// MARK: - View Extension

extension View {
  public func defaultEidRequestToolbar(onClose: (() -> Void)? = nil) -> some View {
    modifier(DefaultEidRequestToolbar(onClose: onClose))
  }
}
