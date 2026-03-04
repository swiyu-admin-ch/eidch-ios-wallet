import BITCredential
import BITCredentialShared

extension PresentationRequestReviewState.Result {
  init(credential: CompatibleCredential, verifierDisplay: VerifierDisplay, colorScheme: String) {
    self.credential = VerifiableCredentialViewModel(credential: credential.credential, colorScheme: colorScheme)
    self.verifierDisplay = verifierDisplay
    claimBadges = credential.requestedClaimClusters
      .flatMap(\.claims)
      .map(ClaimBadgeViewModel.init)
      .sorted { $0.isSensitive && !$1.isSensitive }
    clusters = credential.requestedClaimClusters
  }
}

extension ClaimBadgeViewModel {
  fileprivate init(_ claim: CredentialClaim) {
    name = claim.preferredDisplay.name ?? claim.key
    isSensitive = claim.isSensitive
  }
}

extension PresentationRequestReviewState.Processing {
  init(result: PresentationRequestReviewState.Result) {
    credential = result.credential
    verifierDisplay = result.verifierDisplay
    isMessagePresented = false
  }
}
