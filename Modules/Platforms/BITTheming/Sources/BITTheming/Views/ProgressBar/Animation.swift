import Foundation
import SwiftUI

// MARK: - AnimationStep

public struct AnimationStep {
  let size: CGSize
  let offsetX: CGFloat
  let duration: Double
  let animation: Animation

  public init(size: CGSize, offsetX: CGFloat, duration: Double = 0.5, animation: Animation = .easeInOut) {
    self.size = size
    self.offsetX = offsetX
    self.duration = duration
    self.animation = animation
  }
}

// MARK: - AnimationConfiguration

public struct AnimationConfiguration {

  // MARK: Lifecycle

  public init(
    stepCount: Int = 8,
    baseSize: CGSize = CGSize(width: 235, height: 28),
    offsetRange: ClosedRange<CGFloat> = -120...120,
    baseDuration: Double = 0.5,
    baseAnimation: Animation = .easeInOut,
    shouldLoop: Bool = true)
  {
    self.stepCount = stepCount
    self.baseSize = baseSize
    self.offsetRange = offsetRange
    self.baseDuration = baseDuration
    self.baseAnimation = baseAnimation
    self.shouldLoop = shouldLoop
  }

  // MARK: Internal

  let stepCount: Int
  let baseSize: CGSize
  let offsetRange: ClosedRange<CGFloat>
  let baseDuration: Double
  let baseAnimation: Animation
  let shouldLoop: Bool

}

// MARK: - AnimationSequence

public struct AnimationSequence {

  // MARK: Lifecycle

  public init(steps: [AnimationStep], shouldLoop: Bool = false) {
    self.steps = steps
    self.shouldLoop = shouldLoop
  }

  public init(configuration: AnimationConfiguration) {
    shouldLoop = configuration.shouldLoop
    steps = Self.generateRandomSteps(from: configuration)
  }

  // MARK: Internal

  let steps: [AnimationStep]
  let shouldLoop: Bool

  // Regenerate steps with new random values
  mutating func regenerate(with configuration: AnimationConfiguration) {
    self = AnimationSequence(configuration: configuration)
  }

  // MARK: Private

  private static func generateRandomSteps(from config: AnimationConfiguration) -> [AnimationStep] {
    var steps = [AnimationStep]()
    var currentMinOffset = config.offsetRange.lowerBound

    for _ in 0..<config.stepCount {
      let randomOffset = CGFloat.random(in: currentMinOffset...config.offsetRange.upperBound)

      let step = AnimationStep(
        size: config.baseSize,
        offsetX: randomOffset,
        duration: config.baseDuration,
        animation: config.baseAnimation)

      steps.append(step)

      currentMinOffset = max(currentMinOffset, randomOffset)
    }

    return steps
  }

}

extension AnimationSequence {
  public static let infiniteRandomSequence = AnimationSequence(
    configuration: AnimationConfiguration(
      stepCount: 8,
      baseSize: CGSize(width: 235, height: 28),
      offsetRange: -120...120,
      baseDuration: 0.5,
      baseAnimation: .interpolatingSpring,
      shouldLoop: true)
  )
}

// MARK: - AnimationStateManager

@MainActor
class AnimationStateManager: ObservableObject {

  // MARK: Internal

  @Published var size = CGSize.zero
  @Published var offsetX = CGFloat.zero
  @Published var isAnimating = false

  func startAnimation(sequence: AnimationSequence) {
    guard !isAnimating else { return }

    animationTask?.cancel()
    animationTask = Task {
      await runAnimationSequence(sequence)
    }
  }

  func startAnimation(configuration: AnimationConfiguration) {
    let sequence = AnimationSequence(configuration: configuration)
    startAnimation(sequence: sequence)
  }

  func stopAnimation() {
    animationTask?.cancel()
    isAnimating = false
  }

  func reset() {
    stopAnimation()
    size = .zero
    offsetX = .zero
  }

  // MARK: Private

  private var animationTask: Task<Void, Never>?

  private func runAnimationSequence(_ sequence: AnimationSequence) async {
    isAnimating = true

    repeat {
      var currentSequence = sequence
      if sequence.shouldLoop {
        let config = AnimationConfiguration(
          stepCount: sequence.steps.count,
          baseSize: sequence.steps.first?.size ?? CGSize(width: 235, height: 28),
          offsetRange: -120...120,
          baseDuration: sequence.steps.first?.duration ?? 0.5,
          baseAnimation: sequence.steps.first?.animation ?? .easeInOut,
          shouldLoop: sequence.shouldLoop)
        currentSequence = AnimationSequence(configuration: config)
      }

      for step in currentSequence.steps {
        guard !Task.isCancelled else { return }

        await MainActor.run {
          withAnimation(step.animation) {
            self.size = step.size
            self.offsetX = step.offsetX
          }
        }

        try? await Task.sleep(for: .seconds(step.duration))
      }
    } while sequence.shouldLoop && !Task.isCancelled

    isAnimating = false
  }
}
