#if DEBUG
import Foundation
@testable import BITTestingCore

extension CredentialClaim {

  public struct Mock {
    public static var noDisplays = CredentialClaim(key: "key1", value: "value1")
    public static var withDisplays = CredentialClaim(key: "key2", value: "value2", displays: CredentialClaimDisplay.Mock.array)
    public static var array: [CredentialClaim] = [noDisplays, withDisplays]
  }

}
#endif
