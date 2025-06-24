import SwiftUI

// MARK: - AsyncButton

@MainActor
public struct AsyncButton<Label: View>: View {

  // MARK: Lifecycle

  public init(
    action: @escaping () async -> Void,
    actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
    @ViewBuilder label: @escaping () -> Label)
  {
    self.action = action
    self.actionOptions = actionOptions
    self.label = label
  }

  // MARK: Public

  public var body: some View {
    Button(
      action: {
        if actionOptions.contains(.disableButton) {
          isDisabled = true
        }

        if actionOptions.contains(.showProgressView) {
          showProgressView = true
        }

        Task {
          await action()
          isDisabled = false
          showProgressView = false
        }
      },
      label: {
        HStack {
          if showProgressView {
            ProgressView()
              .controlSize(.regular)
          }

          label()
        }
        .frame(maxWidth: .infinity)
      })
      .disabled(isDisabled)
  }

  // MARK: Internal

  var action: () async -> Void
  var actionOptions = Set(ActionOption.allCases)

  @ViewBuilder var label: () -> Label

  // MARK: Private

  @State private var isDisabled = false
  @State private var showProgressView = false

}

// MARK: AsyncButton.ActionOption

extension AsyncButton {
  public enum ActionOption: CaseIterable {
    case disableButton
    case showProgressView
    case handleError
  }
}
