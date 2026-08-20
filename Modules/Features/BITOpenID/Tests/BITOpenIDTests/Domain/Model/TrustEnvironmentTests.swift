import Factory
import Foundation
import XCTest
@testable import BITOpenID

final class TrustEnvironmentTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testInit_swiyuDid_returnsSwiyu() {
    for did in swiyuDids {
      let environment = TrustEnvironment(did: did)

      XCTAssertEqual(environment, .swiyu, "Should be swiyu: \(did)")
    }
  }

  func testInit_swiyuIntDid_returnsSwiyuInt() {
    for did in swiyuIntDids {
      let environment = TrustEnvironment(did: did)

      XCTAssertEqual(environment, .swiyuInt, "Should be swiyu-int: \(did)")
    }
  }

  func testInit_unknownDid_returnsExternal() {
    for did in unknownDids {
      let environment = TrustEnvironment(did: did)

      XCTAssertEqual(environment, .external, "Should be external: \(did)")
    }
  }

  // MARK: Private

  private let swiyuDids: [String] = [
    "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example",
    "did:webvh:mock:identifier-reg.trust-infra.swiyu.admin.ch:example",
  ]

  private let swiyuIntDids: [String] = [
    "did:tdw:mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "did:webvh:mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
  ]

  private let unknownDids: [String] = [
    "did:tdw:mock:identifier-reg-d.trust-infra.swiyu.admin.ch:example",
    "did:webvh:mock:identifier-reg-d.trust-infra.swiyu.admin.ch:example",
    "did:tdw:mock:identifier-reg-a.trust-infra.swiyu.admin.ch:example",
    "did:webvh:mock:identifier-reg-a.trust-infra.swiyu.admin.ch:example",
    "did:tdw:mock:identifier-reg-a.trust-infra.swiyu-int.admin.ch:example",
    "did:webvh:mock:identifier-reg-a.trust-infra.swiyu-int.admin.ch:example",
    "did:tdw:mock:identifier-reg-r.trust-infra.swiyu.admin.ch:example",
    "did:webvh:mock:identifier-reg-r.trust-infra.swiyu.admin.ch:example",
    "other:tdw:mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    ":tdw:mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "tdw:mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "did:other:mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "did::mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "did:mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "mock:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "did:tdw:identifier-reg.trust-infra.swiyu-int.admin.ch:example",
    "did:tdw:mock:identifier.trust-infra.swiyu-int.admin.ch:example",
    "did:tdw:mock:identifier-reg-no.trust-infra.swiyu-int.admin.ch:example",
    "did:tdw:mock:identifier-reg.trust-infra:.swiyu-int.admin.ch:example",
    "did:tdw:mock:identifier-reg.other.swiyu-int.admin.ch:example",
    "did:tdw:mock:identifier-reg.trust-infra.other.admin.ch:example",
    "did:tdw:mock:identifier-reg.trust-infra.swiyu-int.other.ch:example",
    "did:tdw:mock:identifier-reg.trust-infra.swiyu-int.admin.other:example",
    "did:tdw:mock:identifier-reg.trust-infra.swiyu-int.admin.chexample",
  ]
}
