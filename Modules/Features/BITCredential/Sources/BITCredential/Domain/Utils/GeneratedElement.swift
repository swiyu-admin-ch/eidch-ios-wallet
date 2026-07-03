import BITCredentialShared

enum GeneratedElement {
  case claim(CredentialClaim)
  case cluster(CredentialClaimCluster)

  var claim: CredentialClaim? {
    guard case .claim(let claim) = self else {
      return nil
    }
    return claim
  }

  var cluster: CredentialClaimCluster? {
    guard case .cluster(let cluster) = self else {
      return nil
    }
    return cluster
  }
}
