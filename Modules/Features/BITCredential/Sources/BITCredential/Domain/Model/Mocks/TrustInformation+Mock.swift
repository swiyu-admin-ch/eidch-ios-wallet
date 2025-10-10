#if DEBUG
import Foundation
@testable import BITOpenID
@testable import BITTestingCore

extension TrustInformation {
  public enum Mock {
    public static let trustedIdentity = TrustInformation(identity: .trusted(IdentityTrustStatementPayload.Mock.validSample.resolvedPayload), vcSchema: .notProtected)
    public static let fullyTrusted = TrustInformation(identity: .trusted(IdentityTrustStatementPayload.Mock.validSample.resolvedPayload), vcSchema: .trusted)
    public static let untrustedIdentity = TrustInformation(identity: .untrusted, vcSchema: .notProtected)
    public static let fullyUntrusted = TrustInformation(identity: .untrusted, vcSchema: .untrusted)
  }
}

#endif
