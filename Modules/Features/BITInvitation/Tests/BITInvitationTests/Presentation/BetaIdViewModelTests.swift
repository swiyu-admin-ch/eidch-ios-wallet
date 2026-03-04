import XCTest
@testable import BITInvitation

final class BetaIdViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  func testOpenSettings() {
    let viewModel = BetaIdViewModel(router: mockRouter)

    viewModel.openBetaIdLink()

    XCTAssertTrue(mockRouter.didCallExternalLinkComplete)
    XCTAssertTrue(mockRouter.closeCalled)
  }

  // MARK: Private

  private var mockRouter = InvitationRouterMock()

}
