/// Body content of the Client Attestation request
///
/// - appAttestation: Base64 encoded app attestation
/// - appAssertion: Base64 encoded app assertion
/// - clientData: Client data sent to the backend
public struct ClientAttestationRequestBody: Codable, Equatable {
  let appAttestation: String
  let appAssertion: String
  let clientData: ClientDataObject

  enum CodingKeys: String, CodingKey {
    case appAttestation = "app_attestation"
    case appAssertion = "app_assertion"
    case clientData = "client_data"
  }
}
