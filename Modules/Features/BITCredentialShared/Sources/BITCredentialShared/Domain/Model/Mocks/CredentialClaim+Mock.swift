#if DEBUG
import Foundation
@testable import BITCore

extension CredentialClaim {

  public struct Mock {
    public static let noDisplays = CredentialClaim(path: [.string("key1")], value: "value1")
    public static let withDisplays = CredentialClaim(path: [.string("key2")], value: "value2", displays: CredentialClaimDisplay.Mock.array)
    public static let array: [CredentialClaim] = [noDisplays, withDisplays]
  }

}
#endif
