import BITActivity
import BITNonCompliance

extension TrustInformation {
  public var actorTrust: ActorTrust {
    switch identity {
    case .trusted: .trusted
    case .untrusted: .untrusted
    case .unknown: .unknown
    }
  }

  public var vcSchemaTrust: BITActivity.VcSchemaTrust {
    switch vcSchema {
    case .notProtected: .notProtected
    case .trusted: .trusted
    case .untrusted: .untrusted
    }
  }

  public var actorComplianceStatus: ActorComplianceStatus {
    switch actorCompliance {
    case .compliant: .compliant
    case .notCompliant: .notCompliant
    case .none: .unknown
    }
  }

  public var nonComplianceReasonDisplays: [NonComplianceReasonDisplay] {
    guard case .notCompliant(let reason) = actorCompliance else { return [] }
    return reason.localizedValues.map {
      NonComplianceReasonDisplay(locale: $0.key, value: $0.value)
    }
  }
}
