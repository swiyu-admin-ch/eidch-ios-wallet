import Foundation
import XCTest
@testable import BITOnboarding
@testable import swiyuUITests_App

// MARK: - OnboardingTests

final class OnboardingTests: UITestCase {

  override var arguments: [String] {
    ["-enable-onboarding"]
  }

  func testAppOpensOnStartScreen() {
    let welcomeIntroductionScreen = WelcomeIntroductionScreen(app: app)
    welcomeIntroductionScreen.assertWelcomeIntroductionScreen()
  }

  func testForwardAndBackwardNavigation() {
    let pin = "123456"
    let welcomeScreen = WelcomeIntroductionScreen(app: app)
    let pinCodeInformationScreen = welcomeScreen
      .assertWelcomeIntroductionScreen()
      .tapStart()
      .assertSecurityIntroductionScreen()
      .tapContinue()
      .assertCredentialIntroductionScreen()
      .tapContinue()
      .assertPrivacyPermissionScreen()
      .tapAccept()
      .assertPinCodeInformationScreen()

    let biometricsScreen = pinCodeInformationScreen
      .tapEnterPassword()
      .assertPinCodeScreen()
      .typePin(pin)
      .tapContinue()
      .assertPinCodeConfirmationScreen()
      .typePin(pin)
      .tapContinue()
      .assertBiometricsScreen()

    let currentScreen = biometricsScreen
      .tapBack()
      .assertPinCodeInformationScreen()

    let startScreen = currentScreen
      .tapBack()
      .assertPrivacyPermissionScreen()
      .tapBack()
      .assertCredentialIntroductionScreen()
      .tapBack()
      .assertSecurityIntroductionScreen()
      .tapBack()
      .assertWelcomeIntroductionScreen()

    XCTAssertEqual(startScreen, welcomeScreen)
  }

  func testDynatraceAcceptThenDeclineNavigation() {
    PrivacyPermissionScreen.navigateToAfterLaunchingApp(app)
      .assertPrivacyPermissionScreen()
      .tapAccept()
      .tapBack()
      .tapDecline()
      .assertPinCodeInformationScreen()
  }
}
