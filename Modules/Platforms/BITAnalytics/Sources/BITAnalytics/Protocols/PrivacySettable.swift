import Foundation

public protocol PrivacySettable {
  func applyUserPrivacyPolicy(_ isEnabled: Bool) async
}
