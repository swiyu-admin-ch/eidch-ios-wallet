import XCTest
@testable import BITCredentialShared
@testable import BITOpenID

final class CredentialDisplayTests: XCTestCase {

  func testResolveClaimTemplate_claimsPathPointerPlaceholder_resolvesClaim() {
    let display = CredentialDisplay(locale: "en", summary: "Firstname: {{[\"info\",0]}}")
    let claims = [CredentialClaim(path: [.string("info"), .index(0)], value: "Arthur")]

    let resolvedDisplay = display.resolveClaimTemplate(with: claims)

    XCTAssertEqual(resolvedDisplay.summary, "Firstname: Arthur")
  }
}
