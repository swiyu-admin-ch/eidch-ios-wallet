import Foundation
import SwiftUI

// MARK: - SplashScreenDelegate

protocol SplashScreenDelegate: AnyObject {
  func didCompleteSplashScreen()
}

// MARK: - AnimatedSplashScreenHostingController

@available(iOS 17.0, *)
class AnimatedSplashScreenHostingController: UIHostingController<AnimatedSplashScreen> {

  // MARK: Lifecycle

  init() {
    super.init(rootView: AnimatedSplashScreen())
    rootView = AnimatedSplashScreen(completed: { [weak self] in
      self?.delegate?.didCompleteSplashScreen()
    })
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: Internal

  weak var delegate: (any SplashScreenDelegate)?

}

// MARK: - SplashScreenHostingController

class SplashScreenHostingController: UIHostingController<SplashScreen> {

  // MARK: Lifecycle

  init() {
    super.init(rootView: SplashScreen())
    rootView = SplashScreen(completed: { [weak self] in
      self?.delegate?.didCompleteSplashScreen()
    })
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: Internal

  weak var delegate: (any SplashScreenDelegate)?

}
