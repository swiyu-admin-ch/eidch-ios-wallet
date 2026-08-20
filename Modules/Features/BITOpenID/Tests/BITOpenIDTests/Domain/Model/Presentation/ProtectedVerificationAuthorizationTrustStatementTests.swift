import Factory
import Foundation
import Testing
@testable import BITJWT
@testable import BITOpenID

struct ProtectedVerificationAuthorizationTrustStatementTests {

  @Test
  func decode_valid_returnsStatement() throws {
    let data = ProtectedVerificationAuthorizationTrustStatementJWT.Mock.sampleData

    let result = try JSONDecoder().decode(ProtectedVerificationAuthorizationTrustStatementJWT.self, from: data)

    #expect(result.subject == "did:example:verifier")
    #expect(result.issuedAt == Date(timeIntervalSinceReferenceDate: 1690360968))
    #expect(result.expiredAt == Date(timeIntervalSinceReferenceDate: 1753432968))
    #expect(result.jwtId.uuidString.lowercased() == "07f289d5-8b1f-4604-bf72-53bdcb71ee05")
    #expect(result.authorizedFields == ["field_1", "field_2"])
    #expect(result.status?.statusList.uri == "https://status.domain.ch/api/v1/statuslist/example.jwt")
    #expect(result.status?.statusList.index == 285)
    #expect(result.issuer == nil)
    #expect(result.audience == nil)
    #expect(result.activatedAt == nil)
  }

  @Test
  func decode_emptyAuthorizedFields_throwsError() throws {
    let data = ProtectedVerificationAuthorizationTrustStatementJWT.Mock.emptyAuthorizedFieldsData

    #expect(throws: ProtectedVerificationAuthorizationTrustStatementJWTError.missingAuthorizedFields) {
      try JSONDecoder().decode( ProtectedVerificationAuthorizationTrustStatementJWT.self, from: data)
    }
  }
}
