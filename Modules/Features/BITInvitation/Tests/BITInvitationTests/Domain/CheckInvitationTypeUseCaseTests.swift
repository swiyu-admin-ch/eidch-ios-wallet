// swiftlint:disable force_unwrapping

import BITCore
import Spyable
import XCTest
@testable import BITInvitation

final class CheckInvitationTypeUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    useCase = CheckInvitationTypeUseCase()
  }

  func testExecute_presentation_returnsPresentationType() throws {
    for url in ["openid4vp://bit.com", "swiyu-verify://bit.com"] {
      let invitationURL = URL(string: url)!

      let invitationType = try useCase.execute(url: invitationURL)

      XCTAssertEqual(invitationType, InvitationType.presentation)
    }
  }

  func testExecute_credentialOffer_returnsCredentialOfferType() throws {
    for url in ["openid-credential-offer://bit.com", "swiyu://bit.com"] {
      let invitationURL = URL(string: url)!

      let invitationType = try useCase.execute(url: invitationURL)

      XCTAssertEqual(invitationType, InvitationType.credentialOffer)
    }
  }

  func testExecute_wrongScheme_throwsWrongSchemeError() throws {
    let invitationURL = URL(string: "test://bit.com")!

    XCTAssertThrowsError(try useCase.execute(url: invitationURL)) { error in
      XCTAssertEqual(error as? CheckInvitationTypeError, .wrongScheme)
    }
  }

  // MARK: Private

  private var useCase = CheckInvitationTypeUseCase()
}

// swiftlint:enable all
