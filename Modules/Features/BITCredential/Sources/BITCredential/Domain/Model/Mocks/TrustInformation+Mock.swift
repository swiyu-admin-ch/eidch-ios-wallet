#if DEBUG
import Foundation
@testable import BITCore
@testable import BITOpenID

extension TrustInformation {
  public enum Mock {
    public static let trustedIdentity = TrustInformation(identity: .trusted, vcSchema: .notProtected)
    public static let fullyTrusted = TrustInformation(identity: .trusted, vcSchema: .trusted)
    public static let untrustedIdentity = TrustInformation(identity: .untrusted, vcSchema: .notProtected)
    public static let fullyUntrusted = TrustInformation(identity: .untrusted, vcSchema: .untrusted)
    public static let unknownIdentity = TrustInformation(identity: .unknown, vcSchema: .notProtected)
  }
}

#endif
