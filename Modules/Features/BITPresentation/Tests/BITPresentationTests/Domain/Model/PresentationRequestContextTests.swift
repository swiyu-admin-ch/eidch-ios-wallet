// swiftlint:disable force_unwrapping
import XCTest
@testable import BITCredential
@testable import BITOpenID
@testable import BITPresentation

final class PresentationRequestContextTests: XCTestCase {

  // MARK: Internal

  func testHasVerifiedQuery_withVqPS_returnsTrue() {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let result = context.hasVerifiedQuery

    XCTAssertTrue(result)
  }

  func testHasVerifiedQuery_noIdTSAndNoVqPS_returnsTrue() {
    let context = PresentationRequestContext.Mock.sampleWithoutVerifiedQuery

    let result = context.hasVerifiedQuery

    XCTAssertTrue(result)
  }

  func testHasVerifiedQuery_idTSAndNoVqPS_returnsFalse() {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutVerifiedQuery

    let result = context.hasVerifiedQuery

    XCTAssertFalse(result)
  }

  func testGetVerifierDisplay_trustedOneLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getPreferredVerifierDisplay(considering: ["en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(display.name, "entityName en-US")
    XCTAssertEqual(display.trustInformation.identity, .trusted)
  }

  func testGetVerifierDisplay_trustedMultipleLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getPreferredVerifierDisplay(considering: ["de", "en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "DE_logoUri")
    XCTAssertEqual(display.name, "entityName de-CH")
  }

  func testGetVerifierDisplay_trustedNoLanguage_returnsKeyAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample

    let display = context.getPreferredVerifierDisplay(considering: [])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "logoUri")
    XCTAssertEqual(display.name, "entityName")
  }

  func testGetVerifierDisplay_legacyTrustOneLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust
    context.trustInformation = TrustInformation(identity: .trusted, vcSchema: .notProtected)
    context.legacyVerifierNames = legacyVerifierNames

    let display = context.getPreferredVerifierDisplay(considering: ["en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(display.name, "EN entityName")
    XCTAssertEqual(display.trustInformation.identity, .trusted)

    context.trustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)
    context.legacyVerifierNames = nil
  }

  func testGetVerifierDisplay_legacyTrustMultipleLanguage_returnsTrustedNameAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust
    context.legacyVerifierNames = legacyVerifierNames

    let display = context.getPreferredVerifierDisplay(considering: ["de", "en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "DE_logoUri")
    XCTAssertEqual(display.name, "de-CH entityName")

    context.legacyVerifierNames = nil
  }

  func testGetVerifierDisplay_legacyTrustNoLanguage_returnsKeyAndMetadataLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust
    context.legacyVerifierNames = legacyVerifierNames

    let display = context.getPreferredVerifierDisplay(considering: [])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "logoUri")
    XCTAssertEqual(display.name, "entityName")

    context.legacyVerifierNames = nil
  }

  func testGetVerifierDisplay_untrustedOneLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust

    let display = context.getPreferredVerifierDisplay(considering: ["en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(display.name, "EN Verifier")
    XCTAssertEqual(display.trustInformation.identity, .untrusted)
  }

  func testGetVerifierDisplay_untrustedMultipleLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust

    let display = context.getPreferredVerifierDisplay(considering: ["de", "en"])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "DE_logoUri")
    XCTAssertEqual(display.name, "DE Verifier")
  }

  func testGetVerifierDisplay_untrustedNoLanguage_returnsMetadataNameAndLogo() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust

    let display = context.getPreferredVerifierDisplay(considering: [])

    XCTAssertEqual(try String(data: XCTUnwrap(display.logo), encoding: .utf8), "logoUri")
    XCTAssertEqual(display.name, "Verifier")
  }

  func testVerifierDisplays_trustStatement_returnsAllLocalizedDisplays() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtSample
    context.legacyVerifierNames = legacyVerifierNames

    let displays = context.verifierDisplays
    XCTAssertEqual(displays.count, 5)

    let display1 = try XCTUnwrap(displays.first { $0.locale == "de" })
    XCTAssertEqual(display1.name, "entityName de-CH")
    XCTAssertEqual(try String(data: XCTUnwrap(display1.logo), encoding: .utf8), "DE_logoUri")

    let display2 = try XCTUnwrap(displays.first { $0.locale == "de-CH" })
    XCTAssertEqual(display2.name, "entityName de-CH")
    XCTAssertEqual(try String(data: XCTUnwrap(display2.logo), encoding: .utf8), "DE_logoUri")

    let display3 = try XCTUnwrap(displays.first { $0.locale == "en" })
    XCTAssertEqual(display3.name, "entityName en-US")
    XCTAssertEqual(try String(data: XCTUnwrap(display3.logo), encoding: .utf8), "EN_logoUri")

    let display4 = try XCTUnwrap(displays.first { $0.locale == "en-US" })
    XCTAssertEqual(display4.name, "entityName en-US")
    XCTAssertEqual(try String(data: XCTUnwrap(display4.logo), encoding: .utf8), "EN_logoUri")

    let display5 = try XCTUnwrap(displays.first { $0.locale == "" })
    XCTAssertEqual(display5.name, "entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display5.logo), encoding: .utf8), "logoUri")
  }

  func testVerifierDisplays_legacyTrustStatement_returnsAllLocalizedDisplays() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust
    context.legacyVerifierNames = legacyVerifierNames

    let displays = context.verifierDisplays
    XCTAssertEqual(displays.count, 4)

    let display1 = try XCTUnwrap(displays.first { $0.locale == "de" })
    XCTAssertEqual(display1.name, "de-CH entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display1.logo), encoding: .utf8), "DE_logoUri")

    let display2 = try XCTUnwrap(displays.first { $0.locale == "de-CH" })
    XCTAssertEqual(display2.name, "de-CH entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display2.logo), encoding: .utf8), "DE_logoUri")

    let display3 = try XCTUnwrap(displays.first { $0.locale == "en" })
    XCTAssertEqual(display3.name, "EN entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display3.logo), encoding: .utf8), "EN_logoUri")

    let display4 = try XCTUnwrap(displays.first { $0.locale == "" })
    XCTAssertEqual(display4.name, "entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(display4.logo), encoding: .utf8), "logoUri")

    context.legacyVerifierNames = nil
  }

  func testVerifierDisplays_untrusted_returnsAllLocalizedDisplays() throws {
    let context = PresentationRequestContext.Mock.vcSdJwtWithoutIdentityTrust

    let displays = context.verifierDisplays
    XCTAssertEqual(displays.count, 3)

    let display1 = try XCTUnwrap(displays.first { $0.locale == "de" })
    XCTAssertEqual(display1.name, "DE Verifier")
    XCTAssertEqual(try String(data: XCTUnwrap(display1.logo), encoding: .utf8), "DE_logoUri")

    let display2 = try XCTUnwrap(displays.first { $0.locale == "en" })
    XCTAssertEqual(display2.name, "EN Verifier")
    XCTAssertEqual(try String(data: XCTUnwrap(display2.logo), encoding: .utf8), "EN_logoUri")

    let display3 = try XCTUnwrap(displays.first { $0.locale == "" })
    XCTAssertEqual(display3.name, "Verifier")
    XCTAssertEqual(try String(data: XCTUnwrap(display3.logo), encoding: .utf8), "logoUri")
  }

  // MARK: Private

  private let legacyVerifierNames = ["de-CH": "de-CH entityName", "en": "EN entityName"]
}
