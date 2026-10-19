import BITCore
import BITNavigation
import Factory
import Foundation
import Spyable
import SwiftUI
import UIKit

// MARK: - BiometricChangeRoutes

@Spyable
@MainActor
public protocol BiometricChangeRoutes {
  var delegate: BiometricChangeDelegate? { get }

  func biometricStatusUpdate()
}

@MainActor
extension BiometricChangeRoutes where Self: RouterProtocol {

  public func biometricStatusUpdate() {
    let module = Container.shared.biometricChangeModule()
    let viewController = module.viewController
    let style: OpeningStyle = NavigationPushOpeningStyle()
    module.router.current = style
    open(viewController, as: style)
  }

}
