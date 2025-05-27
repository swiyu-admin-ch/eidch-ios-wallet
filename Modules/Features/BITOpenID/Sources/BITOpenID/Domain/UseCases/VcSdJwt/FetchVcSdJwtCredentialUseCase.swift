import BITAnyCredentialFormat
import BITJWT
import BITSdJWT
import Factory
import Foundation

// MARK: - FetchVcSdJwtCredentialUseCaseError

enum FetchVcSdJwtCredentialUseCaseError: Error {
  case invalidRawJWS
}

// MARK: - FetchVcSdJwtCredentialUseCase

struct FetchVcSdJwtCredentialUseCase: FetchAnyCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for context: FetchCredentialContext) async throws -> AnyCredential {
    var proof: CredentialRequestProof? = nil
    if let keyPair = context.keyPair {
      let payload = JWTProofPayload(audience: context.credentialIssuer, nonce: context.accessToken.cNonce, issuedAt: UInt64(context.createdAt.timeIntervalSince1970))
      let jwtData = try jwsEncoder.encode(payload, using: keyPair)
      guard let rawJws = String(data: jwtData, encoding: .utf8) else { throw FetchVcSdJwtCredentialUseCaseError.invalidRawJWS }
      proof = CredentialRequestProof(jwt: rawJws)
    }

    let credentialBody = CredentialRequestBody(
      format: context.format,
      proof: proof,
      credentialDefinition: CredentialRequestBodyDefinition(types: context.credentialOffers))

    let credentialResponse = try await repository.fetchCredential(
      from: context.credentialEndpoint,
      credentialRequestBody: credentialBody,
      acccessToken: context.accessToken)

    guard
      let credentialData = credentialResponse.rawCredential.data(using: .utf8),
      let vcSdJwt = try? sdJwsDecoder.decode(VcSdJwtPayload.self, from: credentialData)
    else {
      throw FetchAnyVerifiableCredentialError.validationFailed
    }

    do {
      guard try await jwsSignatureValidator.validate(vcSdJwt, did: vcSdJwt.payload.issuer) else {
        throw FetchAnyVerifiableCredentialError.validationFailed
      }
      return vcSdJwt
    } catch JWSSignatureValidatorError.cannotResolveDid(_) {
      throw FetchAnyVerifiableCredentialError.unknownIssuer
    } catch {
      throw error
    }
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol

}
