import BITJWT
import BITSdJWT
import Foundation

// MARK: - TrustStatementV1JWT

public protocol TrustStatementV1JWT: JWT {
  var vct: String { get }
  var statusList: VcSdJwtTokenStatus { get }
}

// MARK: - TrustStatementJWT

public protocol TrustStatementJWT: JWT {
  var status: VcSdJwtTokenStatus? { get }
}
