import BITActivity
import BITCredentialShared
import BITNonCompliance
import BITOpenID
import Foundation

extension Activity {
  init(context: PresentationRequestContext, credential: CompatibleCredential, type: ActivityType) {
    self.init(
      type: type,
      actorTrust: context.trustInformation.actorTrust,
      vcSchemaTrust: context.trustInformation.vcSchemaTrust,
      actorCompliance: context.actorCompliance.actorComplianceStatus,
      nonComplianceData: context.requestObjectJWS.rawJWS,
      nonComplianceReasonDisplays: context.actorCompliance.nonComplianceReasonDisplays,
      claims: credential.uniqueClaimIds.map(ActivityClaim.init),
      actorDisplays: context.verifierDisplays.map(ActivityActorDisplay.init))
  }
}

extension CompatibleCredential {
  fileprivate var uniqueClaimIds: Set<UUID> {
    let allClaims = requestedClaimClusters.flatMap(\.allClaims)
    return Set(allClaims.map(\.id))
  }
}

extension CredentialClaimCluster {
  fileprivate var allClaims: [CredentialClaim] {
    claims + childClusters.flatMap(\.allClaims)
  }
}

extension ActivityActorDisplay {
  fileprivate init(_ display: VerifierDisplay) {
    self.init(
      name: display.name,
      locale: display.locale,
      image: display.logo)
  }
}
