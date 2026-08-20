import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - GetBiometricTypeUseCaseProtocol

@Spyable
public protocol GetBiometricTypeUseCaseProtocol {
  func callAsFunction() -> BiometricType
}

// MARK: - GetBiometricTypeUseCase

struct GetBiometricTypeUseCase: GetBiometricTypeUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() -> BiometricType {
    do {
      guard try validator.validatePolicy(.deviceOwnerAuthenticationWithBiometrics, context: context) else { return .none }
      switch context.biometryType {
      case .touchID: return .touchID
      case .faceID: return .faceID
      default: return .none
      }
    } catch {
      return .none
    }
  }

  // MARK: Private

  @Injected(\.internalContext) private var context: LAContextProtocol
  @Injected(\.localAuthenticationPolicyValidator) private var validator: LocalAuthenticationPolicyValidatorProtocol

}
