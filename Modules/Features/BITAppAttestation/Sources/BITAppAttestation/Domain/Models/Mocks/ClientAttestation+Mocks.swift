#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITTestingCore

extension ClientAttestationPayload: Mockable {
  struct Mock {

    // MARK: Internal

    static let sample: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation")
    static let samplePayload: ClientAttestationPayload = Mocker.decode(fromFile: "client-attestation-payload", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let sampleUnsupportedAlgorithm: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-unsupported-algorithm")
    static let sampleMissingExpiredAt: ClientAttestation = encodePayload(fromFile: "client-attestation-missing-expired-at")
    static let sampleMissingActivatedAt: ClientAttestation = encodePayload(fromFile: "client-attestation-missing-activated-at")
    static let sampleNotTrusted: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-not-trusted")
    static let sampleIncorrectName: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-name")
    static let sampleIncorrectBindingKey: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-binding-key")
    static let sampleIncorrectKid: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-kid")
    static let sampleIncorrectSub: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-sub")
    static let sampleExpired: ClientAttestation = encodePayload(fromFile: "client-attestation-expired")

    // MARK: Private

    private static func decodeClientAttestation(fromFile filename: String) -> ClientAttestation {
      let data = getData(fromFile: filename, ofType: "txt", bundle: Bundle.module) ?? Data()
      // swiftlint: disable force_cast force_try
      return try! JWSDecoder().decode(ClientAttestationPayload.self, from: data)
      // swiftlint: enable force_cast force_try
    }

    private static func encodePayload(
      fromFile filename: String,
      algorithm: JWTAlgorithm = JWTAlgorithm.ES256,
      type: String = "oauth-client-attestation+jwt",
      kid: String = "did:tdw:example.com#key-1",
      bundle: Bundle = Bundle.module)
      -> ClientAttestation
    {
      let clientAttestation: ClientAttestationPayload = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)

      let header = JWSHeader(algorithm: algorithm, type: type, keyIdentifier: kid)

      // swiftlint: enable force_cast force_try
      let payload = JWS(payload: clientAttestation, rawPayload: "", rawJWS: "", header: header)
      return ClientAttestation(payload: payload.payload, rawPayload: payload.rawPayload, rawJWS: payload.rawJWS, header: header)
      // swiftlint: disable force_cast force_try
    }
  }
}
#endif
