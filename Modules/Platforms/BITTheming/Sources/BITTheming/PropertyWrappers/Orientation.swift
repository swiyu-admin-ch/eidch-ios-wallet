import SwiftUI
import UIKit

// MARK: - Orientation

@propertyWrapper
public struct Orientation: DynamicProperty {
  @State private var manager = OrientationManager.shared

  public init() {}

  public var wrappedValue: UIDeviceOrientation {
    manager.type
  }
}

// MARK: - OrientationManager

@Observable
fileprivate class OrientationManager {

  // MARK: Lifecycle

  private init() {
    setupInitialOrientation()
    observeOrientationChanges()
  }

  // MARK: Internal

  static let shared = OrientationManager()

  var type = UIDeviceOrientation.unknown

  let allowedOrientations: [UIDeviceOrientation] = [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight]

  // MARK: Private

  @ObservationIgnored private var observerTokens = [NSObjectProtocol]()

  private func setupInitialOrientation() {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
      return
    }

    updateOrientation(with: scene.interfaceOrientation)
  }

  private func observeOrientationChanges() {
    let token = NotificationCenter.default.addObserver(
      forName: UIDevice.orientationDidChangeNotification,
      object: nil,
      queue: .main)
    { [weak self] _ in
      self?.updateOrientation(with: UIDevice.current.orientation)
    }
    observerTokens.append(token)
  }

  private func updateOrientation(with orientation: UIInterfaceOrientation) {
    switch orientation {
    case .portrait:
      type = .portrait
    case .portraitUpsideDown:
      type = .portraitUpsideDown
    case .landscapeLeft:
      type = .landscapeLeft
    case .landscapeRight:
      type = .landscapeRight
    default:
      return
    }
  }

  private func updateOrientation(with orientation: UIDeviceOrientation) {
    guard allowedOrientations.contains(orientation) else { return }
    type = orientation
  }
}
