import BITLocalAuthentication

// MARK: - DisabledClientAttestationRepository

public struct DisabledClientAttestationRepository: ClientAttestationRepositoryProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func get(using context: LAContextProtocol) async throws -> ClientAttestation {
    throw AttestationServiceRepositoryError.serviceDeactivated
  }

  public func create(_ clientAttestation: ClientAttestation) async throws -> ClientAttestation {
    throw AttestationServiceRepositoryError.serviceDeactivated
  }

  public func delete() throws {}
}
