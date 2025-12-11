import BITActivity
import BITCredentialShared
import BITOpenID
import Foundation

extension Activity {
  init(context: PresentationRequestContext, credential: CompatibleCredential, type: ActivityType) {
    self.init(
      type: type,
      actorTrust: context.trustInformation.actorTrust,
      vcSchemaTrust: context.trustInformation.vcSchemaTrust,
      nonComplianceData: context.presentationRequest.nonComplianceData,
      claims: credential.uniqueClaimIds.map(ActivityClaim.init),
      actorDisplays: context.verifierDisplays.map(ActivityActorDisplay.init))
  }
}

extension CompatibleCredential {
  fileprivate var uniqueClaimIds: Set<UUID> {
    let allClaims = requestedClusteredClaims.flatMap(\.allClaims)
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

extension PresentationRequest {
  fileprivate var nonComplianceData: String? {
    switch self {
    case .plain(let requestObject):
      if let rawData = requestObject.raw {
        return String(data: rawData, encoding: .utf8)
      }
    case .jwt(let jwtRequestObject):
      return jwtRequestObject.rawJWS
    }
    return nil
  }
}
