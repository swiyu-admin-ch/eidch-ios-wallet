import BITCore
import BITNavigation
import Factory
import Foundation
import Spyable
import SwiftUI
import UIKit

// MARK: - ChangePinCodeRoutes

@Spyable
@MainActor
public protocol ChangePinCodeRoutes {
  func changePinCode()
}

@MainActor
extension ChangePinCodeRoutes where Self: RouterProtocol {

  public func changePinCode() {
    let module = Container.shared.changePinCodeModule()
    let viewController = module.viewController
    let style: OpeningStyle = NavigationPushOpeningStyle()
    module.router.current = style
    open(viewController, as: style)
  }

}

// MARK: - ChangePinCodeInternalRoutes

@MainActor
public protocol ChangePinCodeInternalRoutes: ClosableRoutes {

  var context: ChangePinCodeContext { get }

  func currentPinCode()
  func newPinCode()
  func confirmNewPinCode()

}

@MainActor
extension ChangePinCodeInternalRoutes where Self: RouterProtocol {

  public func currentPinCode() {
    let viewController = UIHostingController(rootView: CurrentPinCodeView(self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  public func newPinCode() {
    let viewController = UIHostingController(rootView: NewPinCodeView(self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

  public func confirmNewPinCode() {
    let viewController = UIHostingController(rootView: ConfirmPinCodeView(self))
    open(viewController, as: NavigationPushOpeningStyle())
  }

}
