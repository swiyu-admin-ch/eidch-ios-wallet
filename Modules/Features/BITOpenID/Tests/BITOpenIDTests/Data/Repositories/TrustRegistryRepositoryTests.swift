import Factory
import XCTest
@testable import BITOpenID

final class TrustRegistryRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.trustRegistryMapping.register { self.mockTrustRegistryMapping }
    Container.shared.trustRegistryTrustedDids.register { self.mockTrustedDids }
    repository = TrustRegistryRepository()
  }

  func testGetTrustRegistryDomain_success() {
    let mockBaseRegistry = "mock.base.registry"
    let domain = repository.getTrustRegistryDomain(for: mockBaseRegistry)
    XCTAssertNotNil(domain)
    XCTAssertEqual(domain, "mock.trust.registry")
  }

  func testGetTrustRegistryDomainWrongBaseRegistry_failure() {
    let mockBaseRegistry = "unknown.base.registry"
    let domain = repository.getTrustRegistryDomain(for: mockBaseRegistry)
    XCTAssertNil(domain)
  }

  func testGetTrustedDids() throws {
    let dids = repository.getTrustedDids()
    XCTAssertEqual(dids.count, 3)
    XCTAssertEqual(dids.first, "did:trusted-did-1")
  }

  // MARK: Private

  private var mockTrustRegistryMapping: [String: String] = [
    "mock.base.registry": "mock.trust.registry",
    "mock.base.registry1": "mock.trust.registry1",
    "mock.base.registry2": "mock.trust.registry2",
  ]

  private var mockTrustedDids: [String] = [
    "did:trusted-did-1",
    "did:trusted-did-2",
    "did:trusted-did-3",
  ]

  // swiftlint:disable all
  private var repository: TrustRegistryRepository!
  // swiftlint:enable all
}
