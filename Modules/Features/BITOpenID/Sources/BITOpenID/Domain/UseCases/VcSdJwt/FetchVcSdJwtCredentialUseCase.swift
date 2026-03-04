import BITAnyCredentialFormat
import BITJWT
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - FetchAnyCredentialUseCaseProtocol

@Spyable
protocol FetchAnyCredentialUseCaseProtocol {
  func execute(for context: FetchCredentialContext) async throws -> FetchAnyCredentialResult
}

// MARK: - FetchVcSdJwtCredentialUseCaseError

enum FetchVcSdJwtCredentialUseCaseError: Error {
  case invalidRawJWS
}

// MARK: - FetchVcSdJwtCredentialUseCase

struct FetchVcSdJwtCredentialUseCase: FetchAnyCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for context: FetchCredentialContext) async throws -> FetchAnyCredentialResult {
    let proofs = try createProofs(using: context)
    let body = try credentialRequestBodyGenerator.generate(for: context, proofs: proofs)
    let fetchCredentialResult = try await repository.fetchCredential(with: context, credentialRequest: body)

    if case .credential(let anyCredential) = fetchCredentialResult {
      return try await validateCredential(anyCredential)
    }

    return fetchCredentialResult
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\.credentialRequestBodyGenerator) private var credentialRequestBodyGenerator: CredentialRequestBodyGeneratorProtocol

  private func createProofs(using context: FetchCredentialContext) throws -> CredentialRequest.Proofs? {
    guard let holderBindingContext = context.holderBindingContext else { return nil }

    let jwt = ProofJWT(
      audience: context.credentialIssuer,
      nonce: context.nonce?.cNonce,
      issuedAt: context.createdAt)
    let additionalHeaderParameters: [String: Any] = holderBindingContext.keyAttestationJWS
      .map { [ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue: $0] } ?? [:]
    let jwtData = try jwsEncoder.encode(
      jwt,
      using: holderBindingContext.keyPair,
      additionalHeaderParameters: additionalHeaderParameters)

    guard let rawJws = String(data: jwtData, encoding: .utf8) else { throw FetchVcSdJwtCredentialUseCaseError.invalidRawJWS }

    return CredentialRequest.Proofs(jwt: [rawJws])
  }

  private func validateCredential(_ anyCredential: AnyCredential) async throws -> FetchAnyCredentialResult {
    do {
      guard let vcSdJWS = anyCredential as? VcSdJWS else {
        throw FetchAnyVerifiableCredentialError.validationFailed
      }
      try await jwsSignatureValidator.validate(vcSdJWS, issuerDid: vcSdJWS.payload.requiredIssuer)
      return .credential(vcSdJWS)
    } catch JWSSignatureValidatorError.cannotResolveDid(_) {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    } catch {
      throw error
    }
  }
}
