import Factory
import SwiftUI
import Testing
import UIKit
@testable import swiyu

// swiftlint:disable all

// MARK: - OverlayWindowCoordinatorTests

@MainActor
@Suite
final class OverlayWindowCoordinatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let privacyWindowAnimator = OverlayWindowAnimatingSpy()
    self.privacyWindowAnimator = privacyWindowAnimator
    Container.shared.privacyWindowAnimator.register { privacyWindowAnimator }
  }

  deinit {
    Container.shared.reset()
  }

  // MARK: Internal

  @Test
  func presentPrivacyWindowCreatesOverlayFromAttachedMainWindow() {
    let mainWindow = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 568))
    let overlayWindow = UIWindow(frame: .zero)
    var factoryMainWindow: UIWindow?

    let sut = OverlayWindowCoordinator { mainWindow in
      factoryMainWindow = mainWindow
      return overlayWindow
    }
    sut.attachMainWindow(mainWindow)

    sut.presentPrivacyWindow()

    #expect(factoryMainWindow === mainWindow)
    #expect(privacyWindowAnimator.preparedWindow === overlayWindow)
    #expect(overlayWindow.rootViewController is UIHostingController<PrivacyOverlayView>)
    #expect(overlayWindow.windowLevel == .alert + 2)
    #expect(!overlayWindow.isHidden)
  }

  // MARK: Private

  private var privacyWindowAnimator: OverlayWindowAnimatingSpy!
}

// MARK: - OverlayWindowAnimatingSpy

@MainActor
private final class OverlayWindowAnimatingSpy: OverlayWindowAnimating {

  private(set) var preparedWindow: UIWindow?

  func prepareForPresentation(_ window: UIWindow) {
    preparedWindow = window
  }

  func dismiss(_ window: UIWindow, completion: (() -> Void)?) {
    completion?()
  }
}
