// MARK: - ClientAttestedRequest

///
/// Requst as object, containing the header with `client_attestation` and `client_attestation_POP` and the body
///
public struct ClientAttestedRequest {
  public let body: any Body
  public let header: Header
}

extension ClientAttestedRequest {

  public typealias Body = Encodable & Equatable

  public struct Header {

    public let clientAttestation: String
    public let clientAttestationPoP: String
  }

}
