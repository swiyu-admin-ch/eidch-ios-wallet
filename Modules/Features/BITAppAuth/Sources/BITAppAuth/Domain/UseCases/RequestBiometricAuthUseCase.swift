import BITCore
import BITLocalAuthentication
import Factory
import Foundation
import LocalAuthentication
import Spyable

// MARK: - RequestBiometricAuthUseCaseProtocol

@Spyable
public protocol RequestBiometricAuthUseCaseProtocol {
  func callAsFunction(reason: String, context: LAContextProtocol) async throws
}

// MARK: - RequestBiometricAuthUseCase

struct RequestBiometricAuthUseCase: RequestBiometricAuthUseCaseProtocol {

  func callAsFunction(reason: String, context: LAContextProtocol) async throws {
    NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)
    defer {
      NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
    }

    do {
      guard try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) else {
        throw AuthError.biometricPolicyEvaluationFailed
      }
    } catch LAError.biometryNotAvailable {
      throw AuthError.biometricNotAvailable
    } catch {
      throw error
    }
  }

}
