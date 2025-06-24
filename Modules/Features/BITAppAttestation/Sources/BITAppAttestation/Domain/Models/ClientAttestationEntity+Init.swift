import BITEntities
import Foundation

extension ClientAttestationEntity {

  convenience init(_ clientAttestation: ClientAttestation) {
    self.init()
    id = UUID()
    createdAt = Date()
    attestation = clientAttestation.rawJWS
  }
}
