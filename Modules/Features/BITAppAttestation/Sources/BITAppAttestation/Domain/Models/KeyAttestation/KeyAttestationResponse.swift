/// Mobile backend response of the Key Attestation request
///
/// - keyAttestation: Key Attestation JWT
struct KeyAttestationResponse: Codable, Equatable {
  let keyAttestation: String
}
