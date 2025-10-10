// swiftlint:disable force_unwrapping
import XCTest
@testable import BITOpenID
@testable import BITPresentation

final class PresentationRequestContextTests: XCTestCase {

  func testGetVerifierDisplay_trustedOneLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

    let display = context.getVerifierDisplay(considering: ["en"])

    XCTAssertEqual(String(data: display.logo!, encoding: .utf8)!, "EN_logoUri")
    XCTAssertEqual(display.name, "EN entityName")
    if case .trusted(let statement) = display.trustInformation.identity {
      XCTAssertEqual(statement as? IdentityTrustStatementPayload, IdentityTrustStatementPayload.Mock.validSample.resolvedPayload)
    }
  }

  func testGetVerifierDisplay_trustedMultipleLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

    let display = context.getVerifierDisplay(considering: ["de", "en"])

    XCTAssertEqual(String(data: display.logo!, encoding: .utf8)!, "DE_logoUri")
    XCTAssertEqual(display.name, "de-CH entityName")
  }

  func testGetVerifierDisplay_trustedNoLanguage_returnsKeyAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

    let display = context.getVerifierDisplay(considering: [])

    XCTAssertEqual(String(data: display.logo!, encoding: .utf8)!, "logoUri")
    XCTAssertEqual(display.name, "entityName")
  }

  func testGetVerifierDisplay_untrustedOneLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getVerifierDisplay(considering: ["en"])

    XCTAssertEqual(String(data: display.logo!, encoding: .utf8)!, "EN_logoUri")
    XCTAssertEqual(display.name, "EN Verifier")
    XCTAssertEqual(display.trustInformation.identity, .untrusted)
  }

  func testGetVerifierDisplay_untrustedMultipleLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getVerifierDisplay(considering: ["de", "en"])

    XCTAssertEqual(String(data: display.logo!, encoding: .utf8)!, "DE_logoUri")
    XCTAssertEqual(display.name, "DE Verifier")
  }

  func testGetVerifierDisplay_untrustedNoLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getVerifierDisplay(considering: [])

    XCTAssertEqual(String(data: display.logo!, encoding: .utf8)!, "logoUri")
    XCTAssertEqual(display.name, "Verifier")
  }
}
