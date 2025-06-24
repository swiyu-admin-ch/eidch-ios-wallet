import BITAnyCredentialFormat
import BITJWT
import BITOca
import BITSdJWT
import Factory
import Foundation

struct FetchVcMetadataForVcSdJwtUseCase: FetchVcMetadataForAnyCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(for anyCredential: AnyCredential) async throws -> (VcSchema?, RawOcaBundle?) {
    guard let vcSdJwt = anyCredential as? VcSdJwt else { throw CredentialFormatError.formatNotSupported }
    let typeMetadata = try await typeMetadataService.fetch(vcSdJwt.payload)
    var rawOcaBundle: RawOcaBundle? = nil
    var vcSchema: VcSchema? = nil
    if let metadata = typeMetadata {
      vcSchema = try await vcSchemaService.fetch(for: metadata)
      if let vcSchema {
        let claims = anyCredential.getClaimsDictionary(.all)
        guard try vcSdJwtSchemaValidator.validate(claims, schema: vcSchema) else {
          throw FetchAnyVerifiableCredentialError.invalidVcSchema
        }
      }
      rawOcaBundle = try await fetchOCABundle(from: metadata)
    }
    return (vcSchema, rawOcaBundle)
  }

  // MARK: Private

  @Injected(\.vcSchemaService) private var vcSchemaService: VcSchemaServiceProtocol
  @Injected(\.vcSdJwtSchemaValidator) private var vcSdJwtSchemaValidator: VcSdJwtSchemaValidatorProtocol
  @Injected(\.typeMetadataService) private var typeMetadataService: TypeMetadataServiceProtocol
  @Injected(\.ocaBundleService) private var ocaBundleService: OCABundleServiceProtocol

  private func fetchOCABundle(from typeMetadata: TypeMetadata) async throws -> RawOcaBundle? {
    guard
      let oca = typeMetadata.displays?.first(where: { $0.rendering?.oca != nil })?.rendering?.oca, // OCA localization is not taken in consideration in the display: we take the first one available
      let ocaBundle = try await ocaBundleService.fetchVcSdJwtOcaBundle(from: oca)
    else {
      return nil
    }

    return ocaBundle
  }

}
