// swiftlint:disable force_unwrapping
import BITCore
import Moya
import XCTest
@testable import BITOpenID

final class TrustStatementEndpointTests: XCTestCase {

  func testIdentityTrustStatements() throws {
    let baseUrl = "https://example.com"
    let did = "did:example:1234"
    let url = try XCTUnwrap(URL(string: baseUrl))

    let endpoint = URL(target: TrustStatementEndpoint.identity(url: url, subjectDid: did))

    XCTAssertEqual("\(baseUrl)/api/v1/truststatements/identity/\(did)", endpoint.absoluteString)
  }

  func testVcSchemaTrustStatements() throws {
    for type in VcSchemaTrustStatementType.allCases {
      let baseUrl = "https://example.com"
      let vcSchemaId = "vcSchemaId"
      let url = try XCTUnwrap(URL(string: baseUrl))

      let endpoint = URL(target: TrustStatementEndpoint.vcSchema(url: url, type: type, vcSchemaId: vcSchemaId))

      XCTAssertEqual("\(baseUrl)/api/v1/truststatements/\(type)", endpoint.absoluteString, "VcSchemaTrustStatementType: \(type)")
    }
  }
}
