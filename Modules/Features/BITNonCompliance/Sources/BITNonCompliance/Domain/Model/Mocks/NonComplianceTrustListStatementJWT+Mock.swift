#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

extension NonComplianceTrustListStatementJWT: Mockable {
  public struct Mock {

    // MARK: Public

    public static let rawJWS = "rawJWS"
    public static let rawJWSData = Data(rawJWS.utf8)
    public static let notCompliantReason = LocalizedDisplay(values: ["en": "reason EN"])

    public static let sample: NonComplianceTrustListStatement = createObject(payload: sampleJWT)
    public static let empty: NonComplianceTrustListStatement = createObject(payload: emptyJWT)

    // MARK: Private

    private static let sampleJWT: NonComplianceTrustListStatementJWT = decode(
      fromFile: "non-compliance-trust-list-statement",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)

    private static let emptyJWT: NonComplianceTrustListStatementJWT = decode(
      fromFile: "non-compliance-trust-list-statement-empty",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)

    private static func createObject(payload: NonComplianceTrustListStatementJWT) -> NonComplianceTrustListStatement {
      JWS(
        payload: payload,
        rawPayload: "rawPayload",
        rawJWS: rawJWS,
        header: JWSHeader(algorithm: JWTAlgorithm.ES256))
    }
  }
}
#endif
