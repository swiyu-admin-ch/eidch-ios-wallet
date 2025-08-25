// swiftlint: disable implicitly_unwrapped_optional
import XCTest

// MARK: - UITestCaseProtocol

protocol UITestCaseProtocol {
  var arguments: [String] { get }
  var orientation: UIDeviceOrientation { get }
}

// MARK: - UITestCase

open class UITestCase: XCTestCase, UITestCaseProtocol {

  // MARK: Lifecycle

  convenience init(app: XCUIApplication!) {
    self.init(invocation: nil)
    self.app = app
  }

  // MARK: Open

  open var arguments: [String] {
    ["-disable-onboarding"]
  }

  open var orientation: UIDeviceOrientation {
    .portrait
  }

  open override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app = XCUIApplication()
    XCUIDevice.shared.orientation = orientation
    app.launchArguments.append(contentsOf: arguments)
    app.launch()
    XCTAssertTrue(orientation == .portrait ? XCUIDevice.shared.orientation.isPortrait : XCUIDevice.shared.orientation.isLandscape)
  }

  open override func tearDown() {
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.lifetime = .deleteOnSuccess
    add(attachment)
    app.terminate()
  }

  // MARK: Internal

  var app: XCUIApplication!

}

// swiftlint: enable all
