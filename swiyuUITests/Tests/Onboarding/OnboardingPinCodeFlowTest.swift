import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

final class OnboardingPinCodeFlowTest: UITestCase {

  override var arguments: [String] {
    ["-enable-onboarding"]
  }

  func testShortPinCode() {
    let pinCodeScreen = PinCodeScreen.navigateToAfterLaunchingApp(app)
      .tapContinueShowsErrorMessage()
    for digit in "12345" {
      pinCodeScreen
        .typePin(String(digit))
        .tapContinueShowsErrorMessage()
    }
    pinCodeScreen
      .typePin("6")
      .tapContinue()
      .tapContinueShowsWrongPinError()
      .typePin("123")
      .tapContinueShowsWrongPinError()
      .typePin("456")
      .tapContinue()
      .assertBiometricsScreen()
  }

  func testNonMatchingPinCode() {
    let pinCodeConfirmationScreen = PinCodeScreen.navigateToAfterLaunchingApp(app)
      .typePin("123456")
      .tapContinue()
      .assertPinCodeConfirmationScreen()
    for digit in "1234" {
      pinCodeConfirmationScreen
        .typePin(String(digit))
        .tapContinueShowsWrongPinError()
    }
    pinCodeConfirmationScreen
      .typePin("5")
      .tapContinueNavigatesToPinCodeInformationScreen()
      .assertPinCodeInformationScreen()
  }

  func testLongPinCodeEntry() {
    let longPassword = "QxM5dtwcQ51GOL54C9arEHsTl4b7^BQGQYPmA7C57^SMdsd34%FjBWB2fv^sLfIWmJ3!c!Rb27kqNzVbHqf5DlBRb&522Yhe74KqKIPIrtCh1PuUo3Xal0bE9Y@lrWaA"
    PinCodeScreen.navigateToAfterLaunchingApp(app)
      .typePin(longPassword)
      .tapContinue()
      .assertPinCodeConfirmationScreen()
      .typePin(longPassword)
      .tapContinue()
      .assertBiometricsScreen()
  }

}
