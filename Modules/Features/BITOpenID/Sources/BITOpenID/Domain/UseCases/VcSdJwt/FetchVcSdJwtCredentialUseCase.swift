import BITAnyCredentialFormat
import BITJWT
import BITOca
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

  func execute(for context: FetchCredentialContext) async throws -> (credential: AnyCredential, ocaBundle: RawOcaBundle?) {
    var ocaBundle: RawOcaBundle? = nil
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

      guard let typeMetadata = try await typeMetadataService.fetch(vcSdJwt.payload) else {
        return (vcSdJwt, nil)
      }

      guard let vcSchema = try await vcSchemaService.fetch(for: typeMetadata) else {
        ocaBundle = try await fetchOCABundle(from: typeMetadata)
        return (vcSdJwt, ocaBundle)
      }

      if !vcSchemaService.validate(vcSchema, with: vcSdJwt) {
        throw FetchAnyVerifiableCredentialError.invalidVcSchema
      }

      ocaBundle = try await fetchOCABundle(from: typeMetadata)

      return (vcSdJwt, ocaBundle)
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
  @Injected(\.vcSchemaService) private var vcSchemaService: VcSchemaServiceProtocol
  @Injected(\.typeMetadataService) private var typeMetadataService: TypeMetadataServiceProtocol
  @Injected(\.ocaBundleService) private var ocaBundleService: OCABundleServiceProtocol
  @Injected(\.isOCABundleFetchFeatureEnabled) private var isOCABundleFetchFeatureEnabled: Bool
  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol

  private func fetchOCABundle(from typeMetadata: TypeMetadata) async throws -> RawOcaBundle? {
    guard
      isOCABundleFetchFeatureEnabled,
      let oca = typeMetadata.displays?.first(where: { $0.rendering?.oca != nil })?.rendering?.oca, // OCA localization is not taken in consideration in the display: we take the first one available
      let ocaBundle = try await ocaBundleService.fetchVcSdJwtOcaBundle(from: oca)
    else {
      return nil
    }

    return ocaBundle
  }

}
