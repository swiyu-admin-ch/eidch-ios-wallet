import BITActivity
import BITCredential
import BITNonCompliance

extension ActivityDetail {

  // MARK: Internal

  var actorInformationBadgeTypes: [ActorInformationBadgeType] {
    var badges = [actorTrust.actorInformationBadgeType]

    if let vcSchemaBadgeType = vcSchemaTrust.actorInformationBadgeType(for: type) {
      badges.append(vcSchemaBadgeType)
    }

    if let complianceBadgeType = actorComplianceBadgeType {
      badges.append(complianceBadgeType)
    }

    return badges
  }

  // MARK: Private

  private var actorComplianceBadgeType: ActorInformationBadgeType? {
    guard actorCompliance == .notCompliant else { return nil }
    let reason = nonComplianceReasonDisplay?.value ?? ""
    return .notCompliant(reason: reason)
  }
}

extension ActorTrust {
  var actorInformationBadgeType: ActorInformationBadgeType {
    switch self {
    case .trusted:
      .trusted
    case .untrusted:
      .notTrusted
    case .unknown:
      .unknownTrust
    }
  }
}

extension VcSchemaTrust {
  func actorInformationBadgeType(for type: ActivityType) -> ActorInformationBadgeType? {
    switch self {
    case .trusted:
      type == .issuance ? .legitimateIssuer : .legitimateVerifier
    case .untrusted:
      type == .issuance ? .notLegitimateIssuer : .notLegitimateVerifier
    case .notProtected:
      nil
    }
  }
}
