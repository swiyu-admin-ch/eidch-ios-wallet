import BITTheming
import Factory
import SwiftUI

// MARK: - RecordingButton

struct RecordingButton: View {

  // MARK: Lifecycle

  init(
    state: Binding<RecordingState>,
    onTapInitial: (() -> Void)? = nil,
    onTapRecord: (() -> Void)? = nil,
    onTapLoading: (() -> Void)? = nil,
    onTapSuccess: (() -> Void)? = nil)
  {
    _state = state
    self.onTapInitial = onTapInitial
    self.onTapRecord = onTapRecord
    self.onTapLoading = onTapLoading
    self.onTapSuccess = onTapSuccess
  }

  // MARK: Internal

  var body: some View {
    Button {
      switch state {
      case .initial: onTapInitial?()
      case .recording: onTapRecord?()
      case .loading: onTapLoading?()
      case .success: onTapSuccess?()
      }
    } label: {
      Circle()
        .fill(.thinMaterial)
        .overlay { content }
        .overlay { backgroundShape }
        .frame(width: buttonSize, height: buttonSize)
        .padding(focusBorderMargin)
    }
    .buttonStyle(.plain)
    .contentShape(.accessibility, .circle)
    .shadow(radius: 15)
    .colorScheme(.dark)
    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: state)
  }

  // MARK: Private

  @Binding private var state: RecordingState

  private let onTapInitial: (() -> Void)?
  private let onTapRecord: (() -> Void)?
  private let onTapLoading: (() -> Void)?
  private let onTapSuccess: (() -> Void)?
  private let buttonSize = 72.0
  private let focusBorderMargin = CGFloat.x1

  private var backgroundShape: some View {
    let cornerRadius: CGFloat = switch state {
    case .recording: .x1
    default: 50
    }

    let color: Color = switch state {
    case .initial,
         .recording: .red
    case .loading,
         .success: .clear
    }

    let padding: CGFloat = switch state {
    case .initial,
         .loading,
         .success: .x4
    case .recording: .x5
    }

    return RoundedRectangle(cornerRadius: cornerRadius)
      .foregroundColor(color)
      .padding(padding)
  }

  @ViewBuilder
  private var content: some View {
    switch state {
    case .initial:
      EmptyView()
    case .recording(let recordingType):
      recordingView(recordingType)
    case .loading:
      ProgressView()
        .progressViewStyle(.circular)
        .scaleEffect(1.5)
    case .success:
      Image(systemName: "checkmark")
        .foregroundStyle(ThemingAssets.Fills.secondary.swiftUIColor)
        .font(.system(size: .x6, weight: .bold))
    }
  }

  @ViewBuilder
  private func recordingView(_ recordingType: RecordingType) -> some View {
    if case .countdown(let duration, let timeout) = recordingType {
      let progress = duration / max(1, timeout - 1)
      Circle()
        .trim(from: 0.0, to: progress)
        .stroke(style: StrokeStyle(lineWidth: .x1, lineCap: .round))
        .foregroundStyle(ThemingAssets.Fills.secondary.swiftUIColor)
        .rotationEffect(Angle(degrees: 270.0))
        .padding(.x1 / 2)
        .ignoresSafeArea()
        .animation(.linear(duration: 1), value: progress)
    } else {
      EmptyView()
    }
  }

}
