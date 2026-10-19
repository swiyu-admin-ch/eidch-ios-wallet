import Foundation
import Spyable

@Spyable
public protocol LocalAuthenticationPolicyValidatorProtocol: Sendable {
  func validatePolicy(_ policy: LocalAuthenticationPolicy, context: LAContextProtocol) throws -> Bool
}
