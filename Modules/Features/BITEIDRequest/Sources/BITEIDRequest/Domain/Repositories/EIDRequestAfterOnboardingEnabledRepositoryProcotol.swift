import Spyable

@Spyable
public protocol EIDRequestAfterOnboardingEnabledRepositoryProcotol {
  func set(_ enabled: Bool)
  func get() -> Bool
}
