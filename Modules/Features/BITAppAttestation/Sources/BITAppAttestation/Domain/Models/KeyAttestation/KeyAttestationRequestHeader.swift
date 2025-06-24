/// Header content of the Key Attestation request
///
/// - clientAttestation: Client attestation JWT
/// - clientAttestationPoP: Client attestation Proof of Possession JWT
struct KeyAttestationRequestHeader: Codable, Equatable {
  let clientAttestation: String
  let clientAttestationPoP: String

  enum CodingKeys: String, CodingKey {
    case clientAttestation = "client_attestation"
    case clientAttestationPoP = "client_attestation_POP"
  }
}
