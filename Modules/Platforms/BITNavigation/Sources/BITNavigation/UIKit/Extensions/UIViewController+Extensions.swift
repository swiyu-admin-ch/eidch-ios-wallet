import UIKit

extension UIViewController {
  public var className: String {
    String(describing: Self.self)
  }
}
