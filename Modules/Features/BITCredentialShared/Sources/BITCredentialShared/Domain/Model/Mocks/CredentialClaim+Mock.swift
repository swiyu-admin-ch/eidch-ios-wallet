#if DEBUG
import Foundation
@testable import BITTestingCore

extension CredentialClaim {

  struct Mock {
    static var noDisplays = CredentialClaim(key: "key1", value: "value1")
    static var withDisplays = CredentialClaim(key: "key2", value: "value2", displays: CredentialClaimDisplay.Mock.array)
    static var array: [CredentialClaim] = [noDisplays, withDisplays]
  }

}
#endif
