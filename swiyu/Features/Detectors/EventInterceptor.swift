import ObjectiveC.runtime
import UIKit

// MARK: - EventInterceptor

enum EventInterceptor {

  // MARK: Internal

  static var eventHandler: (UIEvent) -> Void = { userActivityDetector.sendEvent($0) }

  static let userActivityDetector = UserActivityDetector()

  static func install() {
    guard !isInstalled else { return }

    _ = userActivityDetector // start "listening" to events without having to make a screen interaction

    guard
      let originalMethod = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.sendEvent(_:))),
      let swizzledMethod = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.swiyu_sendEvent(_:)))
    else {
      return
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
    isInstalled = true
  }

  static func handleInterceptedEvent(_ event: UIEvent) {
    eventHandler(event)
  }

  // MARK: Private

  private static var isInstalled = false
}

extension UIApplication {
  @objc
  fileprivate func swiyu_sendEvent(_ event: UIEvent) {
    swiyu_sendEvent(event)
    EventInterceptor.handleInterceptedEvent(event)
  }
}
