import Factory
import Spyable

// MARK: - RequestOTPUseCaseProtocol

@Spyable
protocol RequestOTPUseCaseProtocol {
  func callAsFunction(email: String) async throws
}

// MARK: - RequestOTPUseCase

struct RequestOTPUseCase: RequestOTPUseCaseProtocol {
  func callAsFunction(email: String) async throws {
    try await repository.requestOTP(email: email)
  }

  @Injected(\.otpRequestRepository) private var repository
}
