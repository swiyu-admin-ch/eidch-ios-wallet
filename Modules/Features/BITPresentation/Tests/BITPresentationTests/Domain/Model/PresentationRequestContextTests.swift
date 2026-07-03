// swiftlint:disable force_unwrapping
import XCTest
@testable import BITOpenID
@testable import BITPresentation

final class PresentationRequestContextTests: XCTestCase {

  func testGetVerifierDisplay_trustedOneLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

    let display = context.getPreferredVerifierDisplay(considering: ["en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(display.name, "EN entityName")
    if case .trusted(let statement) = display.trustInformation.identity {
      XCTAssertEqual(statement, IdentityTrustStatementJWT.Mock.validSample.resolvedPayload)
    }
  }

  func testGetVerifierDisplay_trustedMultipleLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

    let display = context.getPreferredVerifierDisplay(considering: ["de", "en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "DE_logoUri")
    XCTAssertEqual(display.name, "de-CH entityName")
  }

  func testGetVerifierDisplay_trustedNoLanguage_returnsKeyAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

    let display = context.getPreferredVerifierDisplay(considering: [])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "logoUri")
    XCTAssertEqual(display.name, "entityName")
  }

  func testGetVerifierDisplay_untrustedOneLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getPreferredVerifierDisplay(considering: ["en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(display.name, "EN Verifier")
    XCTAssertEqual(display.trustInformation.identity, .untrusted)
  }

  func testGetVerifierDisplay_untrustedMultipleLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getPreferredVerifierDisplay(considering: ["de", "en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "DE_logoUri")
    XCTAssertEqual(display.name, "DE Verifier")
  }

  func testGetVerifierDisplay_untrustedNoLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getPreferredVerifierDisplay(considering: [])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "logoUri")
    XCTAssertEqual(display.name, "Verifier")
  }

  func testVerifierDisplays_returnsAllLocalizedDisplays() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

    let displays = context.verifierDisplays
    XCTAssertEqual(displays.count, 3)

    // display from clientMetadata merged with trust statement identity de-CH
    let display1 = try XCTUnwrap(displays.first { $0.locale == "de" })
    XCTAssertEqual(display1.name, "de-CH entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display1.logo), encoding: .utf8), "DE_logoUri")

    // display from trust statement identity merged with logo from client metadata
    let display2 = try XCTUnwrap(displays.first { $0.locale == "de-CH" })
    XCTAssertEqual(display2.name, "de-CH entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display2.logo), encoding: .utf8), "logoUri")

    // display from trust statement identity merged with logo from client metadata
    let display3 = try XCTUnwrap(displays.first { $0.locale == "en" })
    XCTAssertEqual(display3.name, "EN entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display3.logo), encoding: .utf8), "EN_logoUri")
  }
}
