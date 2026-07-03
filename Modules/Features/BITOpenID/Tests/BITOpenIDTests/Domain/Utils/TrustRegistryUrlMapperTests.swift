// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class TrustRegistryUrlMapperTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    mapper = TrustRegistryUrlMapper()
  }

  func testMap_validDid_returnsURL() throws {
    let did = "did:tdw:example"
    didResolverSpy.getURLFromReturnValue = try XCTUnwrap(URL(string: "https://\(Self.baseRegistryDomain)/api/v1/did/example"))

    let result = try mapper.map(did: did)

    XCTAssertEqual(result.absoluteString, "https://\(Self.trustRegistryDomain)")
    XCTAssertEqual(didResolverSpy.getURLFromReceivedDid, did)
  }

  func testMap_validIntDid_returnsURL() throws {
    let did = "did:tdw:example"
    didResolverSpy.getURLFromReturnValue = try XCTUnwrap(URL(string: "https://\(Self.baseRegistryDomainInt)/api/v1/did/example"))

    let result = try mapper.map(did: did)

    XCTAssertEqual(result.absoluteString, "https://\(Self.trustRegistryDomainInt)")
    XCTAssertEqual(didResolverSpy.getURLFromReceivedDid, did)
  }

  func testMap_notRegisteredBaseRegistry_throwsError() throws {
    didResolverSpy.getURLFromReturnValue = try XCTUnwrap(URL(string: "https://example.ch/api/v1/did/example"))

    XCTAssertThrowsError(try mapper.map(did: "did:tdw:example")) { error in
      XCTAssertEqual(error as? TrustRegistryUrlMapperError, .cannotParseTrustRegistryDomain)
    }
  }

  func testMap_didResolverThrows_throwsError() throws {
    didResolverSpy.getURLFromThrowableError = TestingError.error

    XCTAssertThrowsError(try mapper.map(did: "did:tdw:example")) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let baseRegistryDomain = "example.swiyu.admin.ch"
  private static let baseRegistryDomainInt = "example.swiyu-int.admin.ch"
  private static let trustRegistryDomain = "trust-registry.ch"
  private static let trustRegistryDomainInt = "trust-registry.ch"

  private var didResolverSpy: DidResolverHelperProtocolSpy!
  private var mapper: TrustRegistryUrlMapper!

  private func registerMocks() {
    didResolverSpy = DidResolverHelperProtocolSpy()

    Container.shared.didResolverHelper.register { self.didResolverSpy }
    Container.shared.trustRegistryMapping.register { [
      Self.baseRegistryDomain: Self.trustRegistryDomain,
      Self.baseRegistryDomainInt: Self.trustRegistryDomainInt,
    ] }
  }
}
