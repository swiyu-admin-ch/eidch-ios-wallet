import BITAnyCredentialFormat
import BITJWT
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - FetchAnyCredentialUseCaseProtocol

@Spyable
protocol FetchAnyCredentialUseCaseProtocol {
  func execute(for context: FetchCredentialContext) async throws -> FetchAnyCredentialResult.Credentials
}

// MARK: - FetchVcSdJwtCredentialUseCaseError

enum FetchVcSdJwtCredentialUseCaseError: Error {
  case invalidRawJWS
}

// MARK: - FetchVcSdJwtCredentialUseCase

struct FetchVcSdJwtCredentialUseCase: FetchAnyCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for context: FetchCredentialContext) async throws -> FetchAnyCredentialResult.Credentials {
    let proofs = try createProofs(using: context)
    let credentialResponseEncryption = try CredentialResponseEncryption(from: context.credentialEncryptionContext)
    let request = CredentialRequest(
      credentialConfigurationId: context.credentialConfigurationId,
      proofs: proofs,
      credentialResponseEncryption: credentialResponseEncryption)
    let fetchCredentialResult = try await repository.fetchCredential(with: context, credentialRequest: request)
    if case .credential(let credentials) = fetchCredentialResult {
      try await validateCredentials(credentials)
    }
    return fetchCredentialResult
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\.sdJwtBatchCredentialConsistencyValidator) private var sdJwtBatchCredentialConsistencyValidator: SdJwtBatchCredentialConsistencyValidatorProtocol

  private func createProofs(using context: FetchCredentialContext) throws -> CredentialRequest.Proofs? {
    guard let bindings = context.holderBindings else { return nil }

    let proofs = try bindings.map { binding in
      let jwt = ProofJWT(
        audience: context.credentialIssuer.absoluteString,
        nonce: context.nonce?.cNonce,
        issuedAt: context.createdAt)
      let additionalHeaderParameters: [String: Any] = binding.keyAttestationJWS
        .map { [ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue: $0] } ?? [:]
      let jwtData = try jwsEncoder.encode(
        jwt,
        using: binding.keyPair,
        additionalHeaderParameters: additionalHeaderParameters)

      guard let rawJws = String(data: jwtData, encoding: .utf8) else { throw FetchVcSdJwtCredentialUseCaseError.invalidRawJWS }
      return rawJws
    }

    return CredentialRequest.Proofs(jwt: proofs)
  }

  private func validateCredentials(_ credentials: [AnyCredential]) async throws {
    do {
      let vcSdJwsCredentials = try credentials.map {
        guard let vcSdJWS = $0 as? VcSdJWS else {
          throw FetchAnyVerifiableCredentialError.validationFailed
        }
        return vcSdJWS
      }
      for credential in vcSdJwsCredentials {
        try await jwsSignatureValidator.validate(credential)
      }

      try sdJwtBatchCredentialConsistencyValidator.validate(vcSdJwsCredentials)
    } catch JWSSignatureValidatorError.cannotResolveDid(_) {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    } catch {
      throw error
    }
  }
}
