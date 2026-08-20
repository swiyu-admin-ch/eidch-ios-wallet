import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - HasDevicePinUseCaseProtocol

@Spyable
public protocol HasDevicePinUseCaseProtocol {
  func callAsFunction() -> Bool
}

// MARK: - HasDevicePinUseCase

struct HasDevicePinUseCase: HasDevicePinUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() -> Bool {
    do {
      return try validator.validatePolicy(.deviceOwnerAuthentication, context: context)
    } catch {
      return false
    }
  }

  // MARK: Private

  @Injected(\.internalContext) private var context: LAContextProtocol
  @Injected(\.localAuthenticationPolicyValidator) private var validator: LocalAuthenticationPolicyValidatorProtocol
}

// MARK: - MockHasDevicePinUseCase

#if DEBUG || targetEnvironment(simulator)
struct MockHasDevicePinUseCase: HasDevicePinUseCaseProtocol {

  init(_ value: Bool = false) {
    self.value = value
  }

  private var value: Bool

  func callAsFunction() -> Bool {
    value
  }
}
#endif
