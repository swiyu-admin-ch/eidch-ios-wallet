import Factory
import Foundation
import XCTest
@testable import BITOpenID

final class ValidateCredentialOfferInvitationUrlUseCaseTests: XCTestCase {

  var sut = ValidateCredentialOfferInvitationUrlUseCase()

  override func setUp() {
    super.setUp()

    Container.shared.additionalCredentialOfferSchemes.register { ["swiyu"] }
    sut = ValidateCredentialOfferInvitationUrlUseCase()
  }

  func testExecute_withInvalidScheme_shouldThrowError() {
    guard let url = URL(string: "http://example.com?credential_offer=someValue") else { XCTFail("URL generation error")
      return
    }

    XCTAssertThrowsError(try sut.execute(url)) { error in
      XCTAssertEqual(error as? ValidateCredentialOfferInvitationUrlError, .unexpectedScheme)
    }
  }

  func testExecute_withNoScheme_shouldThrowError() {
    guard let url = URL(string: "://example.com?credential_offer=someValue") else { XCTFail("URL generation error")
      return
    }

    XCTAssertThrowsError(try sut.execute(url)) { error in
      XCTAssertEqual(error as? ValidateCredentialOfferInvitationUrlError, .unexpectedScheme)
    }
  }

  func testExecute_withMissingQueryParameters_shouldThrowError() {
    guard let url = URL(string: "openid-credential-offer://example.com") else { XCTFail("URL generation error")
      return
    }

    XCTAssertThrowsError(try sut.execute(url)) { error in
      XCTAssertEqual(error as? ValidateCredentialOfferInvitationUrlError, .missingUrlParameters)
    }
  }

  func testExecute_withMissingExpectedOfferParameter_shouldThrowError() {
    guard let url = URL(string: "openid-credential-offer://example.com?not_an_expected_offer=someValue") else { XCTFail("URL generation error")
      return
    }

    XCTAssertThrowsError(try sut.execute(url)) { error in
      XCTAssertEqual(error as? ValidateCredentialOfferInvitationUrlError, .missingExpectedOfferParameter)
    }
  }

  func testExecute_withCannotDecodeParameter_shouldThrowError() {
    guard let url = URL(string: "openid-credential-offer://example.com?credential_offer=someInvalidEncodedValue") else { XCTFail("URL generation error")
      return
    }

    XCTAssertThrowsError(try sut.execute(url)) { error in
      if case DecodingError.dataCorrupted(_) = error {
        // success
      } else {
        XCTFail("Expected DecodingError.dataCorrupted but got \(error)")
      }
    }
  }

  func testExecute_withValidOpenIdUrl_shouldReturnOffer() {
    let validEncodedOffer = "%7B%22credential_issuer%22%3A+%22https%3A%2F%2Fissuer.domain.ch%22%2C+%22credential_configuration_ids%22%3A+%5B%5D%2C+%22credential_configurations_ids%22%3A+%5B%22tergum_dummy_jwt%22%5D%2C+%22grants%22%3A+%7B%22urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Apre-authorized_code%22%3A+%7B%22pre-authorized_code%22%3A+%2262e98891-a8ae-4862-8884-d5bc0cc2ca81%22%2C+%22user_pin_required%22%3A+false%7D%7D%7D"
    guard let url = URL(string: "openid-credential-offer://?credential_offer=\(validEncodedOffer)") else { XCTFail("URL generation error")
      return
    }

    XCTAssertNoThrow(try sut.execute(url))
  }

  func testExecute_withValidSwiyuUrl_shouldReturnOffer() {
    let validEncodedOffer = "%7B%22credential_issuer%22%3A+%22https%3A%2F%2Fissuer.domain.ch%22%2C+%22credential_configuration_ids%22%3A+%5B%5D%2C+%22credential_configurations_ids%22%3A+%5B%22tergum_dummy_jwt%22%5D%2C+%22grants%22%3A+%7B%22urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Apre-authorized_code%22%3A+%7B%22pre-authorized_code%22%3A+%2262e98891-a8ae-4862-8884-d5bc0cc2ca81%22%2C+%22user_pin_required%22%3A+false%7D%7D%7D"
    guard let url = URL(string: "swiyu://?credential_offer=\(validEncodedOffer)") else { XCTFail("URL generation error")
      return
    }

    XCTAssertNoThrow(try sut.execute(url))
  }

}
