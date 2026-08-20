import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - HasBiometricAuthUseCaseProtocol

@Spyable
public protocol HasBiometricAuthUseCaseProtocol {
  func callAsFunction() -> Bool
}

// MARK: - HasBiometricAuthUseCase

struct HasBiometricAuthUseCase: HasBiometricAuthUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() -> Bool {
    do {
      return try validator.validatePolicy(.deviceOwnerAuthenticationWithBiometrics, context: context)
    } catch {
      return false
    }
  }

  // MARK: Private

  @Injected(\.internalContext) private var context: LAContextProtocol
  @Injected(\.localAuthenticationPolicyValidator) private var validator: LocalAuthenticationPolicyValidatorProtocol
}
