import Factory
import Foundation
import Testing
@testable import BITJWT
@testable import BITOpenID

struct VerificationQueryPublicStatementTests {

  @Test
  func decode_valid_returnsStatement() throws {
    let data = VerificationQueryPublicStatementJWT.Mock.validSampleData

    let result = try JSONDecoder().decode(VerificationQueryPublicStatementJWT.self, from: data)

    #expect(result.subject == "did:example:verifier")
    #expect(result.purposeName == "purpose_name")
    #expect(result.purposeDescription == "purpose_description")
    #expect(result.request.type == .dcql)
    #expect(result.request.scope == "scope")
    #expect(result.request.dcqlQuery.query.credentials?.count == 1)
    #expect(result.issuedAt == Date(timeIntervalSinceReferenceDate: 1690360968))
    #expect(result.expiredAt == Date(timeIntervalSinceReferenceDate: 1753432968))
    #expect(result.issuer == nil)
    #expect(result.audience == nil)
    #expect(result.activatedAt == nil)
    #expect(result.status == nil)
  }

  @Test
  func decode_wrongVerificationType_throwsError() throws {
    let data = VerificationQueryPublicStatementJWT.Mock.wrongVerificationTypeData

    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode( VerificationQueryPublicStatementJWT.self, from: data)
    }
  }
}
