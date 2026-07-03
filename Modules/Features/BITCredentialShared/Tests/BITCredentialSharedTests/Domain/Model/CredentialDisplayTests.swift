import Testing
@testable import BITCredentialShared
@testable import BITOpenID

struct CredentialDisplayTests {

  // MARK: Internal

  @Test
  func resolvePathTemplate_oneStringPath_returnsResolvedClaim() {
    let display = CredentialDisplay(locale: Self.localeMock, summary: "Test: {{[\"\(Self.attribute)\"]}}")
    let clusters = [CredentialClaimCluster(claims: [claim])]

    let result = display.resolvePathTemplate(with: clusters)

    #expect(result.summary == "Test: \(Self.attributeResolved)")
  }

  // MARK: Private

  private static let localeMock = "locale"
  private static let attribute = "attribute"
  private static let attributeResolved = "attributeResolved"

  private let claim = CredentialClaim(path: [.string(Self.attribute)], value: Self.attributeResolved)
}
