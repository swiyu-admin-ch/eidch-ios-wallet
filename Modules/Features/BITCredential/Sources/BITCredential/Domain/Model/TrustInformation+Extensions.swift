import BITActivity

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
}
