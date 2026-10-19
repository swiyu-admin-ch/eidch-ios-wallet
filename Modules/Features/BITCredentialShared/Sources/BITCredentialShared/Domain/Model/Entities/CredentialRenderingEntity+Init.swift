import BITEntities

extension CredentialRenderingEntity {

  convenience init(_ credential: CredentialProtocol) {
    self.init()
    issuerDisplays.append(objectsIn: credential.issuerDisplays.map(CredentialIssuerDisplayEntity.init))
    displays.append(objectsIn: credential.displays.map { CredentialDisplayEntity(display: $0) })
    if let verifiableCredential = credential as? VerifiableCredential {
      let sortedClusters = verifiableCredential.clusters.sorted(by: { $0.order < $1.order })
      clusters.append(objectsIn: sortedClusters.map { CredentialClaimClusterEntity(cluster: $0) })
    }
    updateContentHash()
  }
}
