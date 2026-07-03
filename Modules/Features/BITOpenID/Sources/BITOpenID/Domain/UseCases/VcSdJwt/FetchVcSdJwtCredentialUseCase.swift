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
    let body = try credentialRequestBodyGenerator.generate(for: context, proofs: proofs)
    let fetchCredentialResult = try await repository.fetchCredential(with: context, credentialRequest: body)

    switch fetchCredentialResult {
    case .credential(let anyCredential):
      return try await validateCredential(anyCredential)
    case .batch(let credentials):
      return try await validateVcSdJwtBatchCredentials(credentials)
    case .deferred:
      return fetchCredentialResult
    }
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\.credentialRequestBodyGenerator) private var credentialRequestBodyGenerator: CredentialRequestBodyGeneratorProtocol
  @Injected(\.sdJwtBatchCredentialConsistencyValidator) private var sdJwtBatchCredentialConsistencyValidator: SdJwtBatchCredentialConsistencyValidatorProtocol

  private func createProofs(using context: FetchCredentialContext) throws -> CredentialRequest.Proofs? {
    guard let bindings = context.holderBindings else { return nil }

    let proofs = try bindings.map { binding in
      let jwt = ProofJWT(
        audience: context.credentialIssuer,
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

  private func validateCredential(_ anyCredential: AnyCredential) async throws -> FetchAnyCredentialResult.Credentials {
    do {
      return try .credential(await validateVcSdJwtCredentialSignature(anyCredential))
    } catch JWSSignatureValidatorError.cannotResolveDid(_) {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    } catch {
      throw error
    }
  }

  private func validateVcSdJwtCredentialSignature(_ anyCredential: AnyCredential) async throws -> VcSdJWS {
    guard let vcSdJWS = anyCredential as? VcSdJWS else {
      throw FetchAnyVerifiableCredentialError.validationFailed
    }

    try await jwsSignatureValidator.validate(vcSdJWS)
    return vcSdJWS
  }

  private func validateVcSdJwtBatchCredentials(_ credentials: [AnyCredential]) async throws -> FetchAnyCredentialResult.Credentials {
    do {
      var validatedCredentials = [VcSdJWS]()
      validatedCredentials.reserveCapacity(credentials.count)

      for credential in credentials {
        try validatedCredentials.append(await validateVcSdJwtCredentialSignature(credential))
      }

      try sdJwtBatchCredentialConsistencyValidator.validate(validatedCredentials)

      return .batch(credentials: validatedCredentials)
    } catch JWSSignatureValidatorError.cannotResolveDid(_) {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    } catch {
      throw error
    }
  }
}
