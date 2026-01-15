import Foundation
@testable import BITAppAuth
@testable import BITCredential
@testable import BITNavigationTestCore
@testable import BITPresentation

// MARK: - MockPresentationRouter

final class MockPresentationRouter: ClosableRoutesMock, PresentationRouterRoutes, PresentationInternalRoutes, LoginRoutes {

  weak var delegate: PresentationFinishDelegate?

  var didCallCompatibleCredentials = false
  var didCallPresentationReview = false
  var calledPresentationResultState: PresentationRequestResultState?
  var startPresentationContext: PresentationRequestContext?
  var didCallBadgeInformation = false
  var didCallLogin = false

  func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws {
    startPresentationContext = context
  }

  func compatibleCredentials(for inputDescriptorId: InputDescriptorID, context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws {
    didCallCompatibleCredentials = true
  }

  func presentationReview(with context: BITPresentation.PresentationRequestContext) {
    didCallPresentationReview = true
  }

  func presentationResultState(with state: BITPresentation.PresentationRequestResultState, context: BITPresentation.PresentationRequestContext) {
    calledPresentationResultState = state
  }

  func badgeInformation(badgeType: BadgeType) {
    didCallBadgeInformation = true
  }

  func login(animated: Bool) {
    didCallLogin = true
  }
}

// MARK: - MockPresentationFinishDelegate

class MockPresentationFinishDelegate: PresentationFinishDelegate {

  var retryCalled = false
  var cancelCalled = false
  var finishCalled = false

  func retry() {
    retryCalled = true
  }

  func cancel() {
    cancelCalled = true
  }

  func finish(with state: PresentationRequestResultState) async {
    finishCalled = true
  }
}
