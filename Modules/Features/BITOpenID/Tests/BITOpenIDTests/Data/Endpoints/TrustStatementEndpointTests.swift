import BITCore
import Foundation
import Moya
import Testing
@testable import BITOpenID

struct TrustStatementEndpointTests {

  @Test
  func identityTrustStatements() throws {
    let baseUrl = "https://example.com"
    let did = "did:example:1234"
    let url = try #require(URL(string: baseUrl))

    let endpoint = URL(target: TrustStatementEndpoint.identity(url: url, subjectDid: did))

    #expect(endpoint.absoluteString == "\(baseUrl)/api/v1/truststatements/identity/\(did)")
  }

  @Test
  func vcSchemaTrustStatements() throws {
    for type in VcSchemaTrustStatementType.allCases {
      let baseUrl = "https://example.com"
      let vcSchemaId = "vcSchemaId"
      let url = try #require(URL(string: baseUrl))

      let endpoint = URL(target: TrustStatementEndpoint.vcSchema(url: url, type: type, vcSchemaId: vcSchemaId))

      #expect(endpoint.absoluteString == "\(baseUrl)/api/v1/truststatements/\(type)")
    }
  }

  @Test
  func protectedIssuanceTrustListStatement() throws {
    let baseUrl = "https://example.com"
    let url = try #require(URL(string: baseUrl))

    let endpoint = URL(target: TrustStatementEndpoint.protectedIssuanceTrustList(url: url))

    #expect(endpoint.absoluteString == "\(baseUrl)/api/v2/protected-issuance-trust-list")
  }
}
