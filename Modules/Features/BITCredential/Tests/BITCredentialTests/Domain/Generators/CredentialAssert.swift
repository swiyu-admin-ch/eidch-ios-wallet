import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredentialShared

// MARK: - ExpectedClaim

// swiftlint:disable force_unwrapping

struct ExpectedClaim {
  let key: String
  let value: String?
  let valueType: ValueType
  let valueDisplayInfo: String?
  let order: Int16
  let locales: [String]
}

func assertClaimsEqual(_ claims: [CredentialClaim], expectedClaims: [ExpectedClaim]) {
  XCTAssertEqual(claims.count, expectedClaims.count)
  for expectedClaim in expectedClaims {
    let claim = claims.first { "$." + $0.key == expectedClaim.key }!
    XCTAssertEqual(claim.valueType, expectedClaim.valueType.rawValue)
    XCTAssertEqual(claim.value, expectedClaim.value)
    XCTAssertEqual(claim.order, Int(expectedClaim.order))

    XCTAssertEqual(claim.displays.count, expectedClaim.locales.count)
    for locale in expectedClaim.locales {
      assertContainsClaimDisplay(claim, locale: locale, name: "\(expectedClaim.key.replacing("$.", with: "")) \(locale)")
    }
  }
}

private func assertContainsClaimDisplay(_ claim: CredentialClaim, locale: String, name: String) {
  let display = claim.displays.first { $0.locale == locale }!
  XCTAssertEqual(display.name, name)
}

func assertCredentialDisplays(_ displays: [CredentialDisplay], credentialId: UUID, derivedFromOCA: Bool = false) {
  XCTAssertEqual(displays.count, 2)
  XCTAssertEqual(displays[0].name, "credential de-CH")
  XCTAssertEqual(displays[0].backgroundColor, "#ffffff")
  XCTAssertEqual(displays[0].locale, "de-CH")
  XCTAssertNotNil(displays[0].logoBase64)
  XCTAssertEqual(displays[0].summary, "summary de-CH")
  XCTAssertEqual(displays[0].credentialId, credentialId)

  XCTAssertEqual(displays[1].name, "credential en-US")
  XCTAssertEqual(displays[1].backgroundColor, "#000000")
  XCTAssertEqual(displays[1].locale, "en-US")
  XCTAssertNotNil(displays[1].logoBase64)
  XCTAssertEqual(displays[1].summary, "summary en-US")
  XCTAssertEqual(displays[1].credentialId, credentialId)

  if derivedFromOCA {
    XCTAssertEqual(displays[0].theme, "light")
    XCTAssertEqual(displays[1].theme, "light")
  } else {
    XCTAssertEqual(displays[0].logoAltText, "logo.altText de-CH")
    XCTAssertEqual(displays[1].logoAltText, "logo.altText en-US")
  }
}

// swiftlint:enable all
