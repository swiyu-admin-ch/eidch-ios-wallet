import NavigatorUI
import SwiftUI

// MARK: - NavigationReturnToCheckpointTriggerModifier

struct NavigationReturnToCheckpointTriggerModifier<T: Hashable>: ViewModifier {

  // MARK: Internal

  @Binding var trigger: Bool

  let checkpoint: NavigationCheckpoint<T>
  let value: T

  func body(content: Content) -> some View {
    content
      .onChange(of: trigger) { _, trigger in
        if trigger {
          navigator.returnToCheckpointSafely(checkpoint, value: value)
          self.trigger = false
        }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator: Navigator
}

extension View {

  public func navigationReturnToCheckpoint<T: Hashable>(trigger: Binding<Bool>, checkpoint: NavigationCheckpoint<T>, value: T) -> some View {
    modifier(NavigationReturnToCheckpointTriggerModifier(trigger: trigger, checkpoint: checkpoint, value: value))
  }

}
