import BITJWT
import BITSdJWT
import Foundation

// MARK: - TrustStatement

public protocol TrustStatement: JWTValidityPayload {
  var vct: String { get }
  var issuer: String { get }
  var subject: String? { get }
  var issuedAt: Date { get }
  var statusList: VcSdJwtTokenStatusList { get }
}

// MARK: - LocalizedTrustStatement

public protocol LocalizedTrustStatement: TrustStatement {
  var entityNames: [String: String] { get }

  func getLocalizedEntityName(considering languageCodes: [String]) -> String
}
