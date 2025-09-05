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
  case invalidTransactionId
}

// MARK: - FetchVcSdJwtCredentialUseCase

struct FetchVcSdJwtCredentialUseCase: FetchAnyCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for context: FetchCredentialContext) async throws -> FetchAnyCredentialResult {
    let proof = try createProof(using: context)
    let credentialBody = VcSdJwtCredentialRequestBody(format: context.format, proof: proof, vct: context.selectedCredential.vct)
    let fetchCredentialResult = try await repository.fetchCredential(with: context, credentialRequestBody: credentialBody)

    if case .credential(let anyCredential) = fetchCredentialResult {
      return try await validateCredential(anyCredential)
    }

    return fetchCredentialResult
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol

  private func createProof(using context: FetchCredentialContext) throws -> VcSdJwtCredentialRequestBody.Proof? {
    guard let holderBindingContext = context.holderBindingContext else { return nil }

    let payload = JWTProofPayload(
      audience: context.credentialIssuer,
      nonce: context.accessToken.cNonce,
      issuedAt: UInt64(context.createdAt.timeIntervalSince1970))
    let additionalHeaderParameters: [String: Any] = holderBindingContext.keyAttestationJWS
      .map { [JWTProofPayload.AdditionalHeaderParameter.keyAttestation.rawValue: $0] } ?? [:]
    let jwtData = try jwsEncoder.encode(
      payload,
      using: holderBindingContext.keyPair,
      additionalHeaderParameters: additionalHeaderParameters)

    guard let rawJws = String(data: jwtData, encoding: .utf8) else { throw FetchVcSdJwtCredentialUseCaseError.invalidRawJWS }

    return VcSdJwtCredentialRequestBody.Proof(jwt: rawJws)
  }

  private func validateCredential(_ anyCredential: AnyCredential) async throws -> FetchAnyCredentialResult {
    do {
      guard
        let vcSdJwt = anyCredential as? VcSdJwt,
        try await jwsSignatureValidator.validate(vcSdJwt, issuerDid: vcSdJwt.payload.issuer)
      else {
        throw FetchAnyVerifiableCredentialError.validationFailed
      }

      return .credential(vcSdJwt)
    } catch JWSSignatureValidatorError.cannotResolveDid(_) {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    } catch {
      throw error
    }
  }

}
