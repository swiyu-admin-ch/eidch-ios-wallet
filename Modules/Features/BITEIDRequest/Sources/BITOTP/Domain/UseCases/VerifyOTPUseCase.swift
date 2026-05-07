import Factory
import Spyable

// MARK: - VerifyOTPUseCaseProtocol

@Spyable
protocol VerifyOTPUseCaseProtocol {
  func callAsFunction(email: String, code: String) async throws
}

// MARK: - VerifyOTPUseCase

struct VerifyOTPUseCase: VerifyOTPUseCaseProtocol {
  func callAsFunction(email: String, code: String) async throws {
    try await repository.verifyOTP(email: email, code: code)
  }

  @Injected(\.otpRequestRepository) private var repository
}
