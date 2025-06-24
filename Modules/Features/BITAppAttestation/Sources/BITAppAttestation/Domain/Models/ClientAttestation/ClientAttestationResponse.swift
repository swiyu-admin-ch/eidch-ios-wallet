/// Mobile backend response of the Client Attestation request
///
/// - clientAttestation: Client Attestation JWT
struct ClientAttestationResponse: Codable, Equatable {
  let clientAttestation: String
}
