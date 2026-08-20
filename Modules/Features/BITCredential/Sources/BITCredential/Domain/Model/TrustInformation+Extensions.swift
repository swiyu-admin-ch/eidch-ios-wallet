import BITActivity
import BITCore
import BITNonCompliance

extension TrustInformation {
  public var actorTrust: ActorTrust {
    switch identity {
    case .trusted: .trusted
    case .untrusted: .untrusted
    case .unknown: .unknown
    case .trustedCheckApp: .trustedCheckApp
    }
  }

  public var vcSchemaTrust: BITActivity.VcSchemaTrust {
    switch vcSchema {
    case .notProtected: .notProtected
    case .trusted: .trusted
    case .untrusted: .untrusted
    }
  }
}

extension ActorCompliance {
  public var actorComplianceStatus: ActorComplianceStatus {
    switch self {
    case .compliant: .compliant
    case .notCompliant: .notCompliant
    }
  }

  public var nonComplianceReasonDisplays: [NonComplianceReasonDisplay] {
    guard case .notCompliant(let reason) = self else { return [] }
    return reason?.getAllDisplays().map {
      NonComplianceReasonDisplay(locale: $0.key, value: $0.value)
    } ?? []
  }
}
