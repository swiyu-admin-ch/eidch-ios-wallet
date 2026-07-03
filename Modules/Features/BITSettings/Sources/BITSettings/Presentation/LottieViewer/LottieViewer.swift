import BITTheming
import Lottie
import SwiftUI

struct LottieViewer: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      lottie: lottieView,
      contents: [
        .title(animation.title),
      ],
      actions: [
        .primary("Select animation") { _ in
          isAnimationPickerPresented.toggle()
        },
        .secondary(buttonText) { _ in
          toggleAnimation()
        },
      ])
      .lottiePlayback(playbackMode)
      .navigationTitle("Lottie Animation")
      .onChange(of: animation, initial: true, playAnimationIfNeeded)
      .sheet(isPresented: $isAnimationPickerPresented) {
        animationPicker
      }
  }

  // MARK: Private

  private enum DemoAnimation: String, CaseIterable, Identifiable {
    case document
    case face
    case confirmIdentity
    case readPassNfc
    case recordDoc
    case recordPass
    case scanDocBack
    case scanDocFront
    case scanDocPass1
    case scanDocPass2

    // MARK: Internal

    var id: String {
      rawValue
    }

    var title: String {
      switch self {
      case .document: "Document animation"
      case .face: "Face animation"
      case .confirmIdentity: "Confirm Identity"
      case .readPassNfc: "Read Pass NFC"
      case .recordDoc: "Record Document"
      case .recordPass: "Record Passport"
      case .scanDocBack: "Scan Document Back"
      case .scanDocFront: "Scan Document Front"
      case .scanDocPass1: "Scan Document Pass 1"
      case .scanDocPass2: "Scan Document Pass 2"
      }
    }
  }

  @State private var buttonText = "Pause"
  @State private var animation = DemoAnimation.document
  @State private var playbackMode = LottiePlaybackMode.paused(at: .currentFrame)
  @State private var isAnimationPickerPresented = false

  private var lottieView: BITTheming.LottieView {
    switch animation {
    case .document: Lotties.docRecordAnimation
    case .face: Lotties.faceRecordAnimation
    case .confirmIdentity: Lotties.confirmIdentity
    case .readPassNfc: Lotties.readPassNfc
    case .recordDoc: Lotties.recordDoc
    case .recordPass: Lotties.recordPass
    case .scanDocBack: Lotties.scanDocBack
    case .scanDocFront: Lotties.scanDocFront
    case .scanDocPass1: Lotties.scanDocPass1
    case .scanDocPass2: Lotties.scanDocPass2
    }
  }

  private var animationPicker: some View {
    Form {
      Picker("Select Animation", selection: $animation) {
        ForEach(DemoAnimation.allCases) { animation in
          Text(animation.title).tag(animation)
        }
      }
      .pickerStyle(.inline)
    }
    .presentationDetents([.medium, .large])
  }

  private func toggleAnimation() {
    if playbackMode == .paused {
      playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
      buttonText = "Pause"
    } else {
      playbackMode = .paused
      buttonText = "Play"
    }
  }

  private func playAnimationIfNeeded() {
    guard playbackMode == .paused else { return }
    toggleAnimation()
  }
}

#Preview {
  LottieViewer()
}
