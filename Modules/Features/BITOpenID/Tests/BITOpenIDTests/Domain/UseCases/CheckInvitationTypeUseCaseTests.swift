import Factory
import XCTest
@testable import BITOpenID

// swiftlint:disable force_unwrapping

final class CheckInvitationTypeUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.additionalCredentialOfferSchemes.register { ["swiyu"] }
    Container.shared.additionalPresentationSchemes.register { ["swiyu-verify"] }

    useCase = CheckInvitationTypeUseCase()
  }

  func testExecute_presentation_returnsPresentationType() throws {
    for url in ["openid4vp://bit.com", "swiyu-verify://bit.com"] {
      let invitationURL = try XCTUnwrap(URL(string: url))

      let invitationType = try useCase.execute(url: invitationURL)

      XCTAssertEqual(invitationType, InvitationType.presentation)
    }
  }

  func testExecute_credentialOffer_returnsCredentialOfferType() throws {
    for url in ["openid-credential-offer://bit.com", "swiyu://bit.com"] {
      let invitationURL = try XCTUnwrap(URL(string: url))

      let invitationType = try useCase.execute(url: invitationURL)

      XCTAssertEqual(invitationType, InvitationType.credentialOffer)
    }
  }

  func testExecute_wrongScheme_throwsWrongSchemeError() throws {
    let invitationURL = try XCTUnwrap(URL(string: "test://bit.com"))

    XCTAssertThrowsError(try useCase.execute(url: invitationURL)) { error in
      XCTAssertEqual(error as? CheckInvitationTypeError, .wrongScheme)
    }
  }

  // MARK: Private

  private var useCase = CheckInvitationTypeUseCase()
}

// swiftlint:enable all
