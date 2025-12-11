import BITTheming
import SwiftUI

// MARK: - RecordingButton

struct RecordingButton: View {

  // MARK: Lifecycle

  init(state: Binding<Self.State>, action: @escaping () -> Void) {
    _state = state
    self.action = action
  }

  // MARK: Internal

  enum State {
    case initial
    case record
    case loading
    case success
  }

  var body: some View {
    VStack {
      Button(action: action) {
        Color.white
          .clipShape(Circle())
          .overlay {
            backgroundShape
              .padding(15)
              .overlay {
                content(for: state)
              }
          }
      }
      .buttonStyle(.plain)
      .frame(width: buttonSize, height: buttonSize)
      .shadow(radius: 15)
      .animation(.spring(response: 0.5, dampingFraction: 0.6), value: state)
    }
  }

  // MARK: Private

  @Binding private var state: State

  private let action: () -> Void
  private let buttonSize = 72.0

  private var backgroundShape: some View {
    let cornerRadius: CGFloat = switch state {
    case .record: 10
    default: 50
    }

    let color: Color = switch state {
    case .initial: .red
    case .record: .red
    default: .clear
    }

    return RoundedRectangle(cornerRadius: cornerRadius)
      .foregroundColor(color)
  }

  @ViewBuilder
  private func content(for state: State) -> some View {
    switch state {
    case .initial,
         .record:
      EmptyView()
    case .loading:
      ProgressView()
        .progressViewStyle(.circular)
        .scaleEffect(1.5)
    case .success:
      Image(systemName: "checkmark")
        .font(.system(size: 30, weight: .bold))
    }
  }

}
