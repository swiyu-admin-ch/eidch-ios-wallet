import Foundation

public protocol PrivacySettable: Sendable {
  func applyUserPrivacyPolicy(_ isEnabled: Bool) async
}
