import BITCore
import BITCredential
import BITCredentialShared

extension PresentationRequestReviewState.Result {

  // MARK: Lifecycle

  init(credential: CompatibleCredential, verifierDisplay: VerifierDisplay, colorScheme: String) {
    self.credential = VerifiableCredentialViewModel(credential: credential.credential, colorScheme: colorScheme)
    self.verifierDisplay = verifierDisplay
    claimBadges = credential.requestedClaimClusters
      .sorted { $0.order < $1.order }
      .flatMap { Self.getBadges(for: $0) }
      .uniqued()
      .sorted { $0.isSensitive && !$1.isSensitive }
    clusters = credential.requestedClaimClusters
  }

  // MARK: Private

  private static func getBadges(for cluster: CredentialClaimCluster, isParentSensitive: Bool = false) -> [ClaimBadgeViewModel] {
    if cluster.isSimpleArray {
      return [ClaimBadgeViewModel(cluster, isParentSensitive: isParentSensitive)]
    }
    var claimBadges = (
      try? cluster.claims
        .compactGroup(keySelector: \.order, valueTransform: { [ClaimBadgeViewModel($0, isParentSensitive: isParentSensitive)] }) { badges, otherBadges in
          badges + otherBadges
        }) ?? [:]
    for childCluster in cluster.childClusters {
      claimBadges[childCluster.order] = getBadges(for: childCluster, isParentSensitive: isParentSensitive || cluster.isSensitive)
    }
    return claimBadges.sorted { $0.key < $1.key }.flatMap(\.value)
  }
}

extension ClaimBadgeViewModel {
  fileprivate init(_ claim: CredentialClaim, isParentSensitive: Bool) {
    name = claim.preferredDisplay.name ?? claim.path.stringValue
    isSensitive = isParentSensitive || claim.isSensitive
  }

  fileprivate init(_ cluster: CredentialClaimCluster, isParentSensitive: Bool) {
    name = cluster.displays.findDisplayWithFallback()?.name ?? cluster.path.stringValue
    isSensitive = cluster.isSensitive || isParentSensitive
  }
}

extension PresentationRequestReviewState.Processing {
  init(result: PresentationRequestReviewState.Result) {
    credential = result.credential
    verifierDisplay = result.verifierDisplay
    isMessagePresented = false
    progress = nil
  }
}
