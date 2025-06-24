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
    static let sampleExpired: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-expired")
    static let sampleNotTrusted: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-not-trusted")
    static let sampleIncorrectName: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-name")
    static let sampleIncorrectBindingKey: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-binding-key")
    static let sampleIncorrectKid: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-kid")
    static let sampleIncorrectSub: ClientAttestation = decodeClientAttestation(fromFile: "client-attestation-incorrect-sub")

    // MARK: Private

    private static func decodeClientAttestation(fromFile filename: String) -> ClientAttestation {
      let data = getData(fromFile: filename, ofType: "txt", bundle: Bundle.module) ?? Data()
      // swiftlint: disable force_cast force_try
      return try! JWSDecoder().decode(ClientAttestationPayload.self, from: data)
      // swiftlint: enable force_cast force_try
    }
  }
}
#endif
