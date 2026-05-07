import BITTheming
import Lottie
import SwiftUI

struct LottieViewer: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      contents: [
        .heroCard {
          Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
            LottieView(animation: .asset(animation.fileName, bundle: Bundle.module))
              .playbackMode(playbackMode)
              .frame(minWidth: 270, minHeight: 350)
          }
        },
        .title(animation.title),
      ],
      actions: [
        .primary("Switch animation") { _ in
          switchAnimation()
        },
        .secondary(buttonText) { _ in
          toggleAnimation()
        },
      ])
      .navigationTitle("Lottie Animation")
      .onAppear {
        toggleAnimation()
      }
  }

  // MARK: Private

  private enum DemoAnimation {
    case document
    case face

    // MARK: Internal

    var fileName: String {
      switch self {
      case .document:
        Assets.docRecordAnimation.name
      case .face:
        Assets.faceRecordAnimation.name
      }
    }

    var title: String {
      switch self {
      case .document:
        "Document animation"
      case .face:
        "Face animation"
      }
    }
  }

  @State private var buttonText = "Pause"
  @State private var animation = DemoAnimation.document
  @State private var playbackMode = LottiePlaybackMode.paused(at: .currentFrame)

  private func switchAnimation() {
    animation = (animation == .document.self) ? .face : .document
  }

  private func toggleAnimation() {
    if playbackMode == .paused {
      playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .autoReverse))
      buttonText = "Pause"
    } else {
      playbackMode = .paused
      buttonText = "Play"
    }
  }
}

#Preview {
  LottieViewer()
}
