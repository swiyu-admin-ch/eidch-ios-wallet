import Foundation
@testable import BITNavigationTestCore
@testable import BITPresentation

class MockPresentationRouter: ClosableRoutesMock, PresentationRouterRoutes {

  var didCallPresentationRequest = false
  var didCallCompatibleCredentials = false
  var didCallNextCompatibleCredentials = false
  var didCallPresentationReview = false
  var calledPresentationResultState: PresentationRequestResultState?

  func presentationRequest(using context: BITPresentation.PresentationRequestContext) throws {
    didCallPresentationRequest = true
  }

  func compatibleCredentials(for inputDescriptorId: String, and context: PresentationRequestContext) throws {
    didCallCompatibleCredentials = true
  }

  func nextCompatibleCredentials(after inputDescriptorId: String, and context: PresentationRequestContext) throws {
    didCallNextCompatibleCredentials = true
  }

  func presentationReview(with context: PresentationRequestContext) {
    didCallPresentationReview = true
  }

  func presentationResultState(with state: BITPresentation.PresentationRequestResultState, context: BITPresentation.PresentationRequestContext) {
    calledPresentationResultState = state
  }

}
