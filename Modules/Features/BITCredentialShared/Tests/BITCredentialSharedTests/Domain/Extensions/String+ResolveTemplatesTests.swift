// swiftlint: disable force_try

import Foundation
import Testing
@testable import BITClaimsPathPointer
@testable import BITCredentialShared
@testable import BITEntities

@MainActor
struct StringResolveTemplatesTests {

  // MARK: Internal

  @Test
  func resolvePathTemplate_noTemplate_returnsAsIs() {
    let result = "Test".resolvePathTemplates(using: [Self.cluster])

    #expect(result == "Test")
  }

  @Test
  func resolvePathTemplate_oneStringPath_returnsResolvedClaim() {
    let result = "Test: {{[\"\(Self.attribute1)\"]}}".resolvePathTemplates(using: [Self.cluster])

    #expect(result == "Test: \(Self.attribute1Value)")
  }

  @Test
  func resolvePathTemplate_oneStringPathNested_returnsResolvedClaim() throws {
    let claim = try Self.createClaim(path: Self.claim1Path, value: Self.attribute1Value)
    let nestedCluster = try Self.createCluster(claims: [claim])
    let clusters = try [Self.createCluster(childClusters: [nestedCluster])]

    let result = "Test: {{[\"\(Self.attribute1)\"]}}".resolvePathTemplates(using: clusters)

    #expect(result == "Test: \(Self.attribute1Value)")
  }

  @Test
  func resolvePathTemplate_oneStringMultipleClusters_returnsResolvedClaim() throws {
    let claim = try Self.createClaim(path: [.string("other")], value: "otherValue")
    let otherCluster = try Self.createCluster(claims: [claim])

    let result = "Test: {{[\"\(Self.attribute1)\"]}}".resolvePathTemplates(using: [otherCluster, Self.cluster])

    #expect(result == "Test: \(Self.attribute1Value)")
  }

  @Test
  func resolvePathTemplate_multiStringPaths_returnsResolvedClaim() {
    let result = "Test: {{[\"\(Self.attribute1)\"]}} {{[\"\(Self.attribute2)\"]}}".resolvePathTemplates(using: [Self.cluster])

    #expect(result == "Test: \(Self.attribute1Value) \(Self.attribute2Value)")
  }

  @Test
  func resolvePathTemplate_claimWithDisplay_returnsResolvedClaim() throws {
    let display = try CredentialClaimDisplayEntity.Mock.create(locale: "locale", value: Self.attribute2Value, createParent: false)
    let claim = try Self.createClaim(path: Self.claim1Path, value: Self.attribute1Value, displays: [display])
    let cluster = try Self.createCluster(claims: [claim])

    let result = "Test: {{[\"\(Self.attribute1)\"]}}".resolvePathTemplates(using: [cluster])

    #expect(result == "Test: \(Self.attribute2Value)")
  }

  @Test
  func resolvePathTemplate_arrayPathOneClaim_returnsResolvedClaim() {
    let result = "Test: {{[\"\(Self.attribute1)\",0]}}".resolvePathTemplates(using: [Self.arrayCluster])

    #expect(result == "Test: \(Self.attribute1Value)")
  }

  @Test
  func resolvePathTemplate_arrayPathAllClaims_returnsResolvedClaimsJoinedWithDefault() {
    let result = "Test: {{[\"\(Self.attribute1)\",null]}}".resolvePathTemplates(using: [Self.arrayCluster])

    #expect(result == "Test: \(Self.attribute1Value), \(Self.attribute2Value)")
  }

  @Test
  func resolvePathTemplate_arrayPathAllClaimsAndSeparator_returnsResolvedClaimsJoinedWithSeparator() {
    let separator = ":"

    let result = "Test: {{[\"\(Self.attribute1)\",null].join('\(separator)')}}".resolvePathTemplates(using: [Self.arrayCluster])

    #expect(result == "Test: \(Self.attribute1Value)\(separator)\(Self.attribute2Value)")
  }

  @Test
  func resolvePathTemplate_arrayPathNoClaims_returnsEmpty()throws {
    let cluster = try Self.createCluster(claims: [])

    let result = "Test: {{[\"\(Self.attribute1)\",null]}}".resolvePathTemplates(using: [cluster])

    #expect(result == "Test: ")
  }

  @Test
  func resolvePathTemplate_nullValue_returnsDefault() throws {
    let claim = try Self.createClaim(path: [.string(Self.attribute1)], value: nil)
    let clusters = try [Self.createCluster(claims: [claim])]

    let result = "{{[\"\(Self.attribute1)\"]}}".resolvePathTemplates(using: clusters)

    #expect(result == "–")
  }

  @Test
  func resolvePathTemplate_nullValueArray_returnsDefaultJoined() throws {
    let claim1 = try Self.createClaim(path: [.string(Self.attribute1), .index(0)], value: nil)
    let claim2 = try Self.createClaim(path: [.string(Self.attribute1), .index(1)], value: nil)
    let clusters = try [Self.createCluster(claims: [claim1, claim2])]

    let result = "{{[\"\(Self.attribute1)\",null]}}".resolvePathTemplates(using: clusters)

    #expect(result == "–, –")
  }

  @Test
  func resolvePathTemplate_indices_returnsResolvedClaimWithIndex() throws {
    let claim1 = try Self.createClaim(path: [.index(0), .string(Self.attribute1)], value: Self.attribute1Value)
    let claim2 = try Self.createClaim(path: [.index(1), .string(Self.attribute1)], value: Self.attribute2Value)
    let clusters = try [Self.createCluster(claims: [claim1, claim2])]

    let result = "Test: {{[null, \"\(Self.attribute1)\"]}}".resolvePathTemplates(using: clusters, indices: [1])

    #expect(result == "Test: \(Self.attribute2Value)")
  }

  @Test
  func resolvePathTemplate_notAPath_returnsEmpty() {
    let result = "{{notAPath}}".resolvePathTemplates(using: [Self.cluster])

    #expect(result == "")
  }

  @Test
  func resolvePathTemplate_malformedJoin_returnsEmpty() {
    let result = "{{[\"\(Self.attribute1)\",null].join(' '}}".resolvePathTemplates(using: [Self.cluster])

    #expect(result == "")
  }

  // MARK: Private

  private static let localeMock = "locale"
  private static let attribute1 = "attribute1"
  private static let attribute2 = "attribute2"
  private static let attribute1Value = "attribute1Value"
  private static let attribute2Value = "attribute2Value"
  private static let claim1Path: ClaimsPathPointer = [.string(Self.attribute1)]

  @MainActor
  private static let claim1 = try! createClaim(path: claim1Path, value: attribute1Value)
  private static let claim2 = try! createClaim(path: [.string(Self.attribute2)], value: Self.attribute2Value)
  private static let arrayClaim1 = try! createClaim(path: [.string(Self.attribute1), .index(0)], value: Self.attribute1Value)
  private static let arrayClaim2 = try! createClaim(path: [.string(Self.attribute1), .index(1)], value: Self.attribute2Value)

  private static let cluster = try! createCluster(claims: [claim1, claim2])
  private static let arrayCluster = try! createCluster(claims: [arrayClaim1, arrayClaim2])

  private static func createClaim(path: ClaimsPathPointer, value: String?, displays: [CredentialClaimDisplayEntity] = []) throws -> CredentialClaimEntity {
    try CredentialClaimEntity.Mock.create(path: path.stringValue, value: value, displays: displays, createParent: false)
  }

  private static func createCluster(path: ClaimsPathPointer = [], claims: [CredentialClaimEntity] = [], childClusters: [CredentialClaimClusterEntity] = [], displays: [CredentialClaimClusterDisplayEntity] = []) throws -> CredentialClaimClusterEntity {
    try CredentialClaimClusterEntity.Mock.create(path: path.stringValue, claims: claims, childClusters: childClusters, displays: displays, createParent: false)
  }
}
