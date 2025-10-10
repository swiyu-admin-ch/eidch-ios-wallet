// swiftlint:disable implicitly_unwrapped_optional
import BITSdJWT
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITOpenID
@testable import BITTestingCore

final class TrustStatementUrlMapperTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.trustRegistryMapping.register { [
      Self.baseRegistryDomain: Self.trustRegistryDomain,
      Self.baseRegistryDomainInt: Self.trustRegistryDomainInt,
    ] }
    mapper = TrustStatementUrlMapper()
  }

  func testMap_validDid_returnsURL() async throws {
    let result = try mapper.map(did: "did:tdw:example:\(Self.baseRegistryDomain):example")

    XCTAssertEqual(result.absoluteString, "https://\(Self.trustRegistryDomain)")
  }

  func testMap_validIntDid_returnsURL() async throws {
    let result = try mapper.map(did: "did:tdw:example:\(Self.baseRegistryDomainInt):example:other:api")

    XCTAssertEqual(result.absoluteString, "https://\(Self.trustRegistryDomainInt)")
  }

  func testMap_notRegisteredBaseRegistry_throwsError() async throws {
    let subjectDid = "did:tdw:example:example.ch:example"

    XCTAssertThrowsError(try mapper.map(did: subjectDid)) { error in
      XCTAssertEqual(error as? TrustStatementUrlMapperError, .cannotParseTrustRegistryDomain)
    }
  }

  func testMap_invalidDid_throwsError() async throws {
    for did in invalidDids {
      XCTAssertThrowsError(try mapper.map(did: did)) { error in
        XCTAssertEqual(error as? TrustStatementUrlMapperError, .cannotParseTrustRegistryDomain, "Accepted invalid did: \(did)")
      }
    }
  }

  // MARK: Private

  private static let baseRegistryDomain = "example.swiyu.admin.ch"
  private static let baseRegistryDomainInt = "example.swiyu-int.admin.ch"
  private static let trustRegistryDomain = "trust-registry.ch"
  private static let trustRegistryDomainInt = "trust-registry.ch"

  private let invalidDids: [String] = [
    "",
    "invalidDid",
    "did:invalid:example:\(baseRegistryDomain):example",
    "did:example:\(baseRegistryDomain):example",
    "example:\(baseRegistryDomain):example",
    ":example:\(baseRegistryDomain):example",
    "did:tdw:\(baseRegistryDomain):example",
    "did:tdw::\(baseRegistryDomain):example",
    "did:tdw:example:\(baseRegistryDomain):",
    "did:tdw:example:\(baseRegistryDomain)",
    "didtdwexample\(baseRegistryDomain)example",
  ]

  private var mapper: TrustStatementUrlMapper!
}
