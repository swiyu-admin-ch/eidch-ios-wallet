import Foundation

@MainActor
public protocol OnboardingDelegate: AnyObject {
  func didCompleteOnboarding()
}
