import Spyable

@Spyable
protocol OTPEnabledRepositoryProtocol {
  func set(_ enabled: Bool)
  func get() -> Bool
}
