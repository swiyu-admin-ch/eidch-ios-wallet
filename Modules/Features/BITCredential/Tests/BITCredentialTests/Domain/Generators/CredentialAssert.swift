import Testing
@testable import BITAnyCredentialFormat
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITCredentialShared
@testable import BITOpenID

// MARK: - ExpectedClaim

struct ExpectedClaim {
  let path: ClaimsPathPointer
  let value: String?
  let valueType: ValueType
  let valueDisplayInfo: String?
  let order: Int16
  let locales: [String]
}

func assertClaimsEqual(_ claims: [CredentialClaim], expectedClaims: [ExpectedClaim], sourceLocation: SourceLocation = #_sourceLocation) {
  #expect(claims.count == expectedClaims.count, sourceLocation: sourceLocation)
  for expectedClaim in expectedClaims {
    guard let claim = claims.first(where: { $0.path == expectedClaim.path }) else {
      Issue.record("Missing claim with path \(expectedClaim.path)", sourceLocation: sourceLocation)
      continue
    }
    #expect(claim.valueType == expectedClaim.valueType.rawValue, sourceLocation: sourceLocation)
    #expect(claim.value == expectedClaim.value, sourceLocation: sourceLocation)
    #expect(claim.order == Int(expectedClaim.order), sourceLocation: sourceLocation)

    #expect(claim.displays.count == expectedClaim.locales.count, sourceLocation: sourceLocation)
    for locale in expectedClaim.locales {
      var name = ""
      if case .string(let key) = expectedClaim.path.first {
        name = key
      }
      assertContainsClaimDisplay(claim, locale: locale, name: "\(name) \(locale)", sourceLocation: sourceLocation)
    }
  }
}

func assertCredentialDisplays(_ displays: [CredentialDisplay], derivedFromOCA: Bool = false, sourceLocation: SourceLocation = #_sourceLocation) {
  #expect(displays.count == 2, sourceLocation: sourceLocation)
  guard displays.count == 2 else { return }

  #expect(displays[0].name == "credential de-CH", sourceLocation: sourceLocation)
  #expect(displays[0].backgroundColor == "#ffffff", sourceLocation: sourceLocation)
  #expect(displays[0].locale == "de-CH", sourceLocation: sourceLocation)
  #expect(displays[0].logoBase64 != nil, sourceLocation: sourceLocation)
  #expect(displays[0].summary == "summary de-CH", sourceLocation: sourceLocation)

  #expect(displays[1].name == "credential en-US", sourceLocation: sourceLocation)
  #expect(displays[1].backgroundColor == "#000000", sourceLocation: sourceLocation)
  #expect(displays[1].locale == "en-US", sourceLocation: sourceLocation)
  #expect(displays[1].logoBase64 != nil, sourceLocation: sourceLocation)
  #expect(displays[1].summary == "summary en-US", sourceLocation: sourceLocation)

  if derivedFromOCA {
    #expect(displays[0].theme == "light", sourceLocation: sourceLocation)
    #expect(displays[1].theme == "light", sourceLocation: sourceLocation)
  } else {
    #expect(displays[0].logoAltText == "logo.altText de-CH", sourceLocation: sourceLocation)
    #expect(displays[1].logoAltText == "logo.altText en-US", sourceLocation: sourceLocation)
  }
}

private func assertContainsClaimDisplay(_ claim: CredentialClaim, locale: String, name: String, sourceLocation: SourceLocation) {
  guard let display = claim.displays.first(where: { $0.locale == locale }) else {
    Issue.record("Missing claim display for locale \(locale)", sourceLocation: sourceLocation)
    return
  }
  #expect(display.name == name, sourceLocation: sourceLocation)
}
