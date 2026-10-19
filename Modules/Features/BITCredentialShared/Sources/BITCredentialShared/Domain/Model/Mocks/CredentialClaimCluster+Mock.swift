#if DEBUG
import Foundation
@testable import BITCore

extension CredentialClaimCluster {
  public enum Mock {

    // MARK: Public

    public static let singleLevel = CredentialClaimCluster(claims: CredentialClaim.Mock.array)

    public static let singleLevelWithDisplay = CredentialClaimCluster(claims: CredentialClaim.Mock.array, displays: ClusterDisplay.Mock.array)

    public static let level3 = CredentialClaimCluster(
      order: 3,
      claims: level3Claims)
    public static let nestedOneLevel = CredentialClaimCluster(
      claims: level2Claims,
      childClusters: [level3])

    public static let level3WithDisplay = CredentialClaimCluster(
      order: 3,
      claims: level3Claims,
      displays: [ClusterDisplay(locale: UserLocale.defaultLocaleIdentifier, name: "Level 3")])
    public static let nestedOneLevelWithDisplay = CredentialClaimCluster(
      claims: level2Claims,
      childClusters: [level3WithDisplay],
      displays: [ClusterDisplay(locale: UserLocale.defaultLocaleIdentifier, name: "Level 2")])
    public static let nestedTwoLevels = CredentialClaimCluster(claims: level1Claims, childClusters: [nestedOneLevelWithDisplay, nestedOneLevel], displays: ClusterDisplay.Mock.array)
    public static let arrayWithDisplay = [singleLevelWithDisplay, singleLevel]

    public static let arrayWithNested = [singleLevelWithDisplay, nestedTwoLevels]

    // MARK: Private

    private static let level3Claims = [
      CredentialClaim(path: [.string("nested_level3_key1")], value: "nested_level3_value1", order: 1),
    ]

    private static let level2Claims = [
      CredentialClaim(path: [.string("nested_level2_key1")], value: "nested_level2_value1", order: 1),
      CredentialClaim(path: [.string("nested_level2_key2")], value: "nested_level2_value2", order: 2),
    ]

    private static let level1Claims = [
      CredentialClaim(path: [.string("nested_level1_key1")], value: "nested_level1_value1", order: 3),
    ]

  }
}
#endif
