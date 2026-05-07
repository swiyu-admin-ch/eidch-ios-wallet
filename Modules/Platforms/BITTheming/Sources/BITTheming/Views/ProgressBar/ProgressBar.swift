import SwiftUI

// MARK: - ProgressBar

public struct ProgressBar: View {

  // MARK: Lifecycle

  public init(image: Image, sequence: AnimationSequence) {
    self.image = image
    self.sequence = sequence
  }

  // MARK: Public

  public var body: some View {
    PrimitiveProgressBar(image: image, position: animationManager.offsetX)
      .frame(maxWidth: animationManager.size.width, maxHeight: animationManager.size.height)
      .onAppear {
        animationManager.startAnimation(sequence: sequence)
      }
      .onDisappear {
        animationManager.stopAnimation()
      }
  }

  // MARK: Internal

  let image: Image
  let sequence: AnimationSequence

  // MARK: Private

  @State private var animationManager = AnimationStateManager()

}
