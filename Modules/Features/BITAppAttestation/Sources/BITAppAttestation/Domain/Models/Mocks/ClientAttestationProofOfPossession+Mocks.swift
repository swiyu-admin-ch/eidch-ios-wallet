#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITTestingCore

extension ClientAttestationProofOfPossession: Mockable {
  struct Mock {

    // MARK: Internal

    static let sample: ClientAttestationProofOfPossession = decodeClientAttestationProofOfPossession(fromFile: "client-attestation-pop-valid")

    // MARK: Private

    private static func decodeClientAttestationProofOfPossession(
      fromFile filename: String,
      algorithm: JWTAlgorithm = JWTAlgorithm.ES256,
      type: String = "oauth-client-attestation-pop+jwt",
      bundle: Bundle = Bundle.module)
      -> ClientAttestationProofOfPossession
    {
      let payload: ClientAttestationProofOfPossessionPayload = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)
      let header = JWSHeader(algorithm: algorithm, type: type)

      // swiftlint: enable force_cast force_try
      return ClientAttestationProofOfPossession(payload: payload, rawJWS: "", rawPayload: "", header: header)
      // swiftlint: disable force_cast force_try
    }
  }
}
#endif
