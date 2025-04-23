#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

extension TrustStatementPayload: Mockable {
  struct Mock {

    static let allFieldsData: Data = getData(fromFile: "trust-statement-all-fields", ofType: "txt", bundle: Bundle.module) ?? Data()

    static let validSample: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample")
    static let validSamplePayload: TrustStatementPayload = decode(fromFile: "trust-statement-valid-sample", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let validSampleItalian: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample-italian")
    static let sdJwtSample: String = getString(fromFile: "trust-statement-sd-jwt", bundle: Bundle.module)

    static func encodePayload(fromFile filename: String, bundle: Bundle = Bundle.module) -> TrustStatement {
      let trustStatement: TrustStatementPayload = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)
      let rawPayload = getString(fromFile: filename, ofType: "json", bundle: bundle)
      return createSdJWSMock(from: trustStatement, rawPayload: rawPayload)
    }

    static func createSdJWSMock(from trustStatement: TrustStatementPayload, rawPayload: String? = nil) -> TrustStatement {
      SdJWS(payload: trustStatement, rawPayload: rawPayload ?? "rawPayload", header: JWSHeader(algorithm: JWTAlgorithm.ES256), raw: "raw", rawJWS: "rawJWS", disclosableClaims: [])
    }
  }
}
#endif
