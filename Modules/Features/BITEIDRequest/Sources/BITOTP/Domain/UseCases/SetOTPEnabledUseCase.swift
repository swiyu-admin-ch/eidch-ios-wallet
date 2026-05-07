import Factory
import Spyable

// MARK: - SetOTPEnabledUseCaseProtocol

@Spyable
public protocol SetOTPEnabledUseCaseProtocol {
  func callAsFunction(_ enabled: Bool)
}

// MARK: - SetOTPEnabledUseCase

struct SetOTPEnabledUseCase: SetOTPEnabledUseCaseProtocol {
  func callAsFunction(_ enabled: Bool) {
    otpEnabledRepository.set(enabled)
  }

  @Injected(\.otpEnabledRepository) private var otpEnabledRepository: OTPEnabledRepositoryProtocol
}
