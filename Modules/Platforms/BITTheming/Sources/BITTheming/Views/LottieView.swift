import Lottie
import SwiftUI

// MARK: - LottieView

public struct LottieView: View {

  // MARK: Lifecycle

  public init(
    animationFile file: String,
    darkModeFile: String? = nil,
    in bundle: Bundle)
  {
    defaultAnimation = LottieAnimation.named(file, bundle: bundle)
    darkAnimation = if let darkModeFile {
      LottieAnimation.named(darkModeFile, bundle: bundle)
    } else {
      nil
    }
  }

  // MARK: Public

  public var body: some View {
    Lottie.LottieView(animation: animation)
      .playbackMode(lottiePlaybackMode)
  }

  // MARK: Private

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.lottiePlaybackMode) private var lottiePlaybackMode

  private let defaultAnimation: LottieAnimation?
  private let darkAnimation: LottieAnimation?

  private var animation: LottieAnimation? {
    switch colorScheme {
    case .dark: darkAnimation ?? defaultAnimation
    case .light: defaultAnimation
    @unknown default: defaultAnimation
    }
  }

}

// MARK: - LottiePlaybackModeKey

private struct LottiePlaybackModeKey: EnvironmentKey {
  static let defaultValue = LottiePlaybackMode.playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
}

extension EnvironmentValues {
  public var lottiePlaybackMode: LottiePlaybackMode {
    get { self[LottiePlaybackModeKey.self] }
    set { self[LottiePlaybackModeKey.self] = newValue }
  }
}

extension View {
  public func lottiePlayback(_ mode: LottiePlaybackMode) -> some View {
    environment(\.lottiePlaybackMode, mode)
  }
}
