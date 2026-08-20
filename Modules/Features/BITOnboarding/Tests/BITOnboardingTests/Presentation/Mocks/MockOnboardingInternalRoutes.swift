import Foundation
@testable import BITOnboarding

final class MockOnboardingInternalRoutes: OnboardingInternalRoutes {

  var context = BITOnboarding.OnboardingContext()

  var closeCalled = false
  var infoScreenWelcomeCalled = false
  var infoScreenCredentialCalled = false
  var infoScreenActivitiesCalled = false
  var infoScreenSecurityCalled = false
  var privacyPermissionCalled = false
  var pinCodeCalled = false
  var pinCodeConfirmationCalled = false
  var pinCodeInformationCalled = false
  var biometricsCalled = false
  var setupCalled = false
  var linkCalled = false
  var popCalled = false
  var completedCalled = false
  var setupErrorCalled = false

  var lastContext: OnboardingContext?
  var lastURL: URL?

  func close() {
    closeCalled = true
  }

  func infoScreenWelcome() {
    infoScreenWelcomeCalled = true
  }

  func infoScreenCredential() {
    infoScreenCredentialCalled = true
  }

  func infoScreenActivities() {
    infoScreenActivitiesCalled = true
  }

  func infoScreenSecurity() {
    infoScreenSecurityCalled = true
  }

  func privacyPermission() {
    privacyPermissionCalled = true
  }

  func pinCodeInformation() {
    pinCodeInformationCalled = true
  }

  func pinCode() {
    pinCodeCalled = true
  }

  func pinCodeConfirmation() {
    pinCodeConfirmationCalled = true
  }

  func biometrics() {
    biometricsCalled = true
  }

  func setup() {
    setupCalled = true
  }

  func completed() {
    completedCalled = true
  }

  func setupError(delegate: SetupDelegate) {
    setupErrorCalled = true
  }

  func openExternalLink(url: URL) {
    linkCalled = true
    lastURL = url
  }

  func dismiss() {}
  func pop() {
    popCalled = true
  }

  func popToRoot() {}
  func pop(count: Int) {}
  func close(onComplete: (() -> Void)?) {}
}
