import Foundation
import Spyable

@Spyable
public protocol VersionEnforcementDelegate: AnyObject {
  func didDismissVersionEnforcement()
}
