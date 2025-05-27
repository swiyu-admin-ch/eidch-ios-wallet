import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredentialShared

// MARK: - ExpectedClaim

// swiftlint:disable force_unwrapping

struct ExpectedClaim {
  let key: String
  let value: String
  let valueType: ValueType
  let order: Int16
  let locales: [String]
}

func assertClaimsEqual(_ claims: [CredentialClaim], expectedClaims: [ExpectedClaim], credentialId: UUID) {
  XCTAssertEqual(claims.count, expectedClaims.count)
  for expectedClaim in expectedClaims {
    let claim1 = claims.first { $0.key == expectedClaim.key }!
    XCTAssertEqual(claim1.valueType, expectedClaim.valueType.rawValue)
    XCTAssertEqual(claim1.value, expectedClaim.value)
    XCTAssertEqual(claim1.order, expectedClaim.order)
    XCTAssertEqual(claim1.credentialId, credentialId)

    XCTAssertEqual(claim1.displays.count, expectedClaim.locales.count)
    for locale in expectedClaim.locales {
      assertContainsClaimDisplay(claim1, locale: locale, name: "\(expectedClaim.key) \(locale)")
    }
  }
}

private func assertContainsClaimDisplay(_ claim: CredentialClaim, locale: String, name: String) {
  let display = claim.displays.first { $0.locale == locale }!
  XCTAssertEqual(display.name, name)
  XCTAssertEqual(display.claimId, claim.id)
}

func assertCredentialDisplays(_ displays: [CredentialDisplay], credentialId: UUID) {
  XCTAssertEqual(displays.count, 2)
  XCTAssertEqual(displays[0].name, "credential de-CH")
  XCTAssertEqual(displays[0].backgroundColor, "#ffffff")
  XCTAssertEqual(displays[0].locale, "de-CH")
  XCTAssertEqual(displays[0].logoAltText, "logo.altText de-CH")
  XCTAssertNotNil(displays[0].logoBase64)
  XCTAssertEqual(displays[0].summary, "summary de-CH")
  XCTAssertEqual(displays[0].credentialId, credentialId)

  XCTAssertEqual(displays[1].name, "credential en-US")
  XCTAssertEqual(displays[1].backgroundColor, "#000000")
  XCTAssertEqual(displays[1].locale, "en-US")
  XCTAssertEqual(displays[1].logoAltText, "logo.altText en-US")
  XCTAssertNotNil(displays[1].logoBase64)
  XCTAssertEqual(displays[1].summary, "summary en-US")
  XCTAssertEqual(displays[1].credentialId, credentialId)
}

// swiftlint:enable all
