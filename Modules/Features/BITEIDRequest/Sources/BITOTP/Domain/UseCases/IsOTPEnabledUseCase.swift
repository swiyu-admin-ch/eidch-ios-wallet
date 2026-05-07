import Factory
import Spyable

// MARK: - IsOTPEnabledUseCaseProtocol

@Spyable
public protocol IsOTPEnabledUseCaseProtocol {
  func callAsFunction() -> Bool
}

// MARK: - IsOTPEnabledUseCase

struct IsOTPEnabledUseCase: IsOTPEnabledUseCaseProtocol {
  func callAsFunction() -> Bool {
    otpEnabledRepository.get()
  }

  @Injected(\.otpEnabledRepository) private var otpEnabledRepository: OTPEnabledRepositoryProtocol
}
