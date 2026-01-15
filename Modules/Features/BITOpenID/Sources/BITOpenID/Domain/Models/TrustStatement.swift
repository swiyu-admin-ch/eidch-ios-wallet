import BITJWT
import BITSdJWT
import Foundation

// MARK: - TrustStatement

public protocol TrustStatement: JWT {
  var vct: String { get }
  var statusList: VcSdJwtTokenStatusList { get }
}
