public struct DisabledAppAttestationRepository: AttestationServiceRepositoryProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func fetchChallenge() async throws -> AttestationChallenge {
    throw AttestationServiceRepositoryError.serviceDeactivated
  }

  public func fetchClientAttestation(_ requestBody: ClientAttestationRequestBody) async throws -> ClientAttestation {
    throw AttestationServiceRepositoryError.serviceDeactivated
  }

  public func fetchKeyAttestation(body: KeyAttestationRequestBody, clientAttestation: ClientAttestation) async throws -> KeyAttestation {
    throw AttestationServiceRepositoryError.serviceDeactivated
  }

  public func fetchBatchKeyAttestation(body: [KeyAttestationRequestBody], clientAttestation: ClientAttestation) async throws -> [KeyAttestation] {
    throw AttestationServiceRepositoryError.serviceDeactivated
  }
}
