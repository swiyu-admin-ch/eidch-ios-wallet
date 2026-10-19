import BITLocalAuthentication
import Factory
import Foundation
import LocalAuthentication
import Spyable

// MARK: - GetBiometricStateUseCaseProtocol

@Spyable
public protocol GetBiometricStateUseCaseProtocol: Sendable {
  func callAsFunction() -> BiometricState
}

// MARK: - GetBiometricStateUseCase

struct GetBiometricStateUseCase: GetBiometricStateUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() -> BiometricState {
    switch biometricAvailability() {
    case .notEnrolled:
      .notEnrolled
    case .unavailable:
      .declined
    case .available:
      biometricRepository.getBiometricUsage().toBiometricState()
    }
  }

  // MARK: Private

  @Injected(\.internalContext) private var context: LAContextProtocol
  @Injected(\.biometricRepository) private var biometricRepository: BiometricRepositoryProtocol
  @Injected(\.localAuthenticationPolicyValidator) private var validator: LocalAuthenticationPolicyValidatorProtocol

  private func biometricAvailability() -> BiometricAvailability {
    do {
      return try validator.validatePolicy(.deviceOwnerAuthenticationWithBiometrics, context: context) ? .available : .unavailable
    } catch {
      switch LAError.Code(rawValue: (error as NSError).code) {
      case .biometryNotEnrolled:
        return .notEnrolled
      default:
        return .unavailable
      }
    }
  }
}
