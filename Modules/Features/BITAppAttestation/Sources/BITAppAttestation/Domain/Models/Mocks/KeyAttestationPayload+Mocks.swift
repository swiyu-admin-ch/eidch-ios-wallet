#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITTestingCore

extension KeyAttestationPayload: Mockable {
  enum Mock {

    // MARK: Internal

    static let sample: KeyAttestation = encodePayload(fromFile: "key-attestation-valid")
    static let samplePayload: KeyAttestationPayload = Mocker.decode(fromFile: "key-attestation-valid", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let sampleUnsupportedAlgorithm: KeyAttestation = encodePayload(fromFile: "key-attestation-valid", algorithm: .ES384)
    static let sampleInvalidKid: KeyAttestation = encodePayload(fromFile: "key-attestation-valid", kid: "did:tdw:mock.com#key-1")
    static let sampleMissingExpiredAt: KeyAttestation = encodePayload(fromFile: "key-attestation-missing-expired-at")
    static let sampleNotTrusted: KeyAttestation = encodePayload(fromFile: "key-attestation-not-trusted")
    static let sampleUnsupportedKeyStorage: KeyAttestation = encodePayload(fromFile: "key-attestation-unsupported-key-storage")
    static let sampleInvalidAttestedKeys: KeyAttestation = encodePayload(fromFile: "key-attestation-invalid-attested-keys")
    static let sampleEmptyAttestedKeys: KeyAttestation = encodePayload(fromFile: "key-attestation-empty-attested-keys")

    // MARK: Private

    private static func encodePayload(
      fromFile filename: String,
      algorithm: JWTAlgorithm = JWTAlgorithm.ES256,
      type: String = "key-attestation+jwt",
      kid: String = "did:tdw:example.com#key-1",
      bundle: Bundle = Bundle.module)
      -> KeyAttestation
    {
      let keyAttestation: KeyAttestationPayload = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)

      let header = JWSHeader(algorithm: algorithm, type: type, keyIdentifier: kid)

      // swiftlint: enable force_cast force_try
      let payload = JWS(payload: keyAttestation, rawPayload: "", rawJWS: "", header: header)
      return KeyAttestation(payload: payload.payload, rawPayload: payload.rawPayload, rawJWS: payload.rawJWS, header: header)
      // swiftlint: disable force_cast force_try
    }
  }
}
#endif
