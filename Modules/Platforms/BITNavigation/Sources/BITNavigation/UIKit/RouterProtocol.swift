import Foundation
import UIKit

// MARK: - RouterProtocol

public protocol RouterProtocol: AnyObject {
  associatedtype View: UIViewController
  var viewController: View? { get }
  var current: OpeningStyle? { get set }

  func open(_ viewController: UIViewController, on parentViewController: UIViewController?, as style: OpeningStyle)
}

extension RouterProtocol {
  public func open(_ viewController: UIViewController, as style: OpeningStyle) {
    open(viewController, on: nil, as: style)
  }
}
